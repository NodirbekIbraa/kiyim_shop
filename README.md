# VESTRA — Ulgurji kiyim CRM

Node.js + Express + PostgreSQL asosidagi ulgurji savdo CRM tizimi. Admin panel orqali
buyurtmalar, mijozlar, mahsulotlar va hisobotlarni boshqarish mumkin. Loyiha Docker'da
ishlaydi va AWS'ga to'liq deploy qilinadi.

- **Stack:** Node.js 20, Express, PostgreSQL 16, vanilla JS admin panel, Nginx (reverse proxy)
- **Dizayn:** binafsha (`#7C3AED`) + yashil (`#10B981`) jewel-tone uslub, Plus Jakarta Sans shrift
- **Kirish:** `nodir@gmail.com` / `univernodir`

---

## 1. Loyiha tuzilmasi

```
vestra/
├── backend/                # Express API
│   ├── routes/             # auth, products, orders, customers, reports, dashboard
│   ├── middleware/auth.js  # JWT tekshiruvi
│   ├── db.js               # PostgreSQL pool
│   ├── server.js
│   └── .env.example
├── database/schema.sql     # Jadvallar + demo ma'lumotlar (birinchi ishga tushishda yuklanadi)
├── frontend/admin/         # Login + dashboard sahifalari
├── nginx/nginx.conf        # Reverse proxy (AWS ALB'ni taqlid qiladi)
├── Dockerfile              # Ko'p bosqichli (multi-stage) build
├── docker-compose.yml      # db + app + nginx
└── README.md
```

---

## 2. Lokalda Docker bilan ishga tushirish

Kerak: **Docker** va **Docker Compose** (Docker Desktop ichida mavjud).

```bash
# 1. Loyiha papkasiga kiring
cd vestra

# 2. Hammasini build qilib ishga tushiring
docker compose up --build

# 3. Brauzerda oching
#    http://localhost  →  login sahifasiga yo'naltiradi
```

Kirish: **nodir@gmail.com** / **univernodir**

To'xtatish va ma'lumotlar bazasini tozalash:

```bash
docker compose down -v      # -v volume'ni ham o'chiradi (DB tozalanadi)
```

> `docker compose` uchta servisni ko'taradi:
> - `db` — PostgreSQL (faqat ichki tarmoqda, tashqaridan ochiq emas → AWS private subnet'dagi RDS kabi)
> - `app` — Node.js backend (tashqariga port ochmaydi → private subnet'dagi ECS/EC2 kabi)
> - `nginx` — yagona tashqi kirish nuqtasi, 80-port (AWS ALB kabi)

---

## 3. Docker'siz lokal ishga tushirish (ixtiyoriy)

```bash
# PostgreSQL'da bazani yarating va schema'ni yuklang
createdb vestra_db
psql -d vestra_db -f database/schema.sql

# Backend
cd backend
cp .env.example .env        # DB ma'lumotlarini moslang
npm install
npm run dev                 # http://localhost:3000/admin/login.html
```

---

## 4. AWS'ga deploy qilish — to'liq qo'llanma

Arxitektura: **Nginx/ALB → ECS Fargate (Node app) → RDS PostgreSQL**, image'lar **ECR**'da saqlanadi.

```
   Internet
      │
   [ ALB ]                  ← Application Load Balancer (public subnet)
      │
 [ ECS Fargate task ]       ← Node.js app (private subnet)  ← image ECR'dan
      │
 [ RDS PostgreSQL ]         ← ma'lumotlar bazasi (private subnet)
```

### 4.0. Tayyorgarlik

1. AWS hisob qaydnomasi va **AWS CLI** o'rnatilgan bo'lsin:
   ```bash
   aws configure        # Access Key, Secret Key, region (masalan eu-west-1)
   ```
2. O'zgaruvchilarni belgilab oling (o'zingiznikiga moslang):
   ```bash
   export AWS_REGION=eu-west-1
   export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
   export ECR_REPO=vestra-app
   ```

### 4.1. Image'ni ECR'ga yuklash

```bash
# 1. ECR repository yarating
aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION

# 2. Docker'ni ECR'ga login qiling
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 3. Image'ni build qiling, teg qo'ying va push qiling
docker build -t $ECR_REPO .
docker tag  $ECR_REPO:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
```

### 4.2. RDS PostgreSQL yaratish

Konsol orqali yoki CLI bilan:

```bash
aws rds create-db-instance \
  --db-instance-identifier vestra-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 16 \
  --allocated-storage 20 \
  --master-username postgres \
  --master-user-password 'KUCHLI_PAROL_KIRITING' \
  --db-name vestra_db \
  --no-publicly-accessible \
  --vpc-security-group-ids sg-XXXXXXXX \
  --region $AWS_REGION
```

Muhim sozlamalar:
- **Publicly accessible: No** — baza faqat private subnet ichida ko'rinadi.
- Security group: faqat ECS task'ning security group'idan **5432**-portga ruxsat bering.
- RDS tayyor bo'lgach **endpoint** manzilini oling:
  ```bash
  aws rds describe-db-instances --db-instance-identifier vestra-db \
    --query 'DBInstances[0].Endpoint.Address' --output text
  # masalan: vestra-db.xxxxxxxx.eu-west-1.rds.amazonaws.com
  ```

Schema'ni RDS'ga yuklang (bostion host yoki ECS task ichidan):

```bash
psql "host=<RDS_ENDPOINT> port=5432 dbname=vestra_db user=postgres password=<PAROL>" \
  -f database/schema.sql
```

### 4.3. ECS Fargate'da ishga tushirish

1. **ECS cluster** yarating (Fargate):
   ```bash
   aws ecs create-cluster --cluster-name vestra-cluster --region $AWS_REGION
   ```

2. **Task definition** (`task-def.json`) — environment'da RDS endpoint'ini bering:
   ```json
   {
     "family": "vestra-task",
     "networkMode": "awsvpc",
     "requiresCompatibilities": ["FARGATE"],
     "cpu": "256",
     "memory": "512",
     "executionRoleArn": "arn:aws:iam::<ACCOUNT_ID>:role/ecsTaskExecutionRole",
     "containerDefinitions": [
       {
         "name": "vestra-app",
         "image": "<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/vestra-app:latest",
         "portMappings": [{ "containerPort": 3000, "protocol": "tcp" }],
         "environment": [
           { "name": "PORT",        "value": "3000" },
           { "name": "DB_HOST",     "value": "<RDS_ENDPOINT>" },
           { "name": "DB_PORT",     "value": "5432" },
           { "name": "DB_NAME",     "value": "vestra_db" },
           { "name": "DB_USER",     "value": "postgres" },
           { "name": "DB_PASSWORD", "value": "<PAROL>" },
           { "name": "JWT_SECRET",  "value": "<TASODIFIY_UZUN_MAXFIY_KALIT>" }
         ],
         "healthCheck": {
           "command": ["CMD-SHELL", "wget -qO- http://localhost:3000/health || exit 1"],
           "interval": 30, "timeout": 5, "retries": 3, "startPeriod": 15
         }
       }
     ]
   }
   ```
   > Ishlab chiqarishda parol va `JWT_SECRET`'ni **AWS Secrets Manager** orqali bering.

   ```bash
   aws ecs register-task-definition --cli-input-json file://task-def.json --region $AWS_REGION
   ```

3. **ALB** (Application Load Balancer) yarating, target group'ning health check yo'lini
   `/health` qilib qo'ying (port 3000).

4. **ECS service** yarating va ALB'ga ulang:
   ```bash
   aws ecs create-service \
     --cluster vestra-cluster \
     --service-name vestra-svc \
     --task-definition vestra-task \
     --desired-count 2 \
     --launch-type FARGATE \
     --network-configuration "awsvpcConfiguration={subnets=[subnet-AAA,subnet-BBB],securityGroups=[sg-APP],assignPublicIp=DISABLED}" \
     --load-balancers "targetGroupArn=arn:aws:...:targetgroup/vestra-tg/...,containerName=vestra-app,containerPort=3000" \
     --region $AWS_REGION
   ```

5. Brauzerda **ALB DNS** manzilini oching:
   ```bash
   aws elbv2 describe-load-balancers --names vestra-alb \
     --query 'LoadBalancers[0].DNSName' --output text
   ```
   Kirish: **nodir@gmail.com** / **univernodir**

### 4.4. HTTPS va domen (ixtiyoriy)

- **ACM**'da bepul SSL sertifikat oling, ALB'ning 443-listener'iga ulang.
- **Route 53**'da domeningizni ALB'ga yo'naltiring.

---

## 5. Xavfsizlik bo'yicha eslatmalar (production'dan oldin)

- `JWT_SECRET`'ni majburiy ravishda **tasodifiy uzun kalit**ga o'zgartiring (environment orqali).
- DB parolini va maxfiy kalitlarni **Secrets Manager / SSM Parameter Store**'da saqlang, kodda emas.
- RDS va ECS'ni **private subnet**'da ushlang; faqat ALB public bo'lsin.
- Security group'larda eng kam ruxsat tamoyiliga amal qiling (ALB→app:3000, app→db:5432).
- Birinchi kirgandan keyin admin parolini almashtiring.

---

## 6. API endpoint'lar (qisqacha)

| Metod  | Yo'l                       | Tavsif                         |
|--------|----------------------------|--------------------------------|
| POST   | `/api/auth/login`          | Tizimga kirish (JWT qaytaradi) |
| GET    | `/api/dashboard/summary`   | Bosh sahifa statistikasi       |
| GET    | `/api/products`            | Mahsulotlar ro'yxati           |
| POST   | `/api/products`            | Mahsulot qo'shish              |
| GET    | `/api/orders`              | Buyurtmalar                    |
| PATCH  | `/api/orders/:id/status`   | Buyurtma holatini o'zgartirish |
| GET    | `/api/customers`           | Mijozlar                       |
| GET    | `/api/reports/summary`     | Hisobotlar (grafiklar uchun)   |
| GET    | `/health`                  | Health check (ALB uchun)       |

Himoyalangan endpoint'lar `Authorization: Bearer <token>` sarlavhasini talab qiladi.
