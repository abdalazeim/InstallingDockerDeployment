<div dir="rtl" align="right">

# InstallingDockerCommand.md — تثبيت Docker Engine + Docker Compose + Portainer (Ubuntu)
## المرحلة 1: تثبيت فقط — بدون أي ربط/تكامل

> **النطاق:** تثبيت **Docker Engine** و**Docker Compose (plugin)** و**Portainer CE** على Ubuntu والتحقق فقط. **لا ربط** مع Jenkins/Ansible/Traefik/Odoo/CI.  
> **التشغيل:** Docker Engine/Compose على المضيف **Native**. Portainer كحاوية Docker (واجهة إدارة). (لا تثبيت Ansible داخل Docker).  
> **الأمان الافتراضي:** ربط Portainer على `127.0.0.1` (وصول محلي فقط). يمكن لاحقًا وضعه خلف Traefik **بعد PASS وبطلب مستقل (Phase 2)** دون كشف المنافذ مباشرة.  
> **تنظيم فقط:** لا حذف؛ الأصل في `legacy/`. لا ادعاء نجاح اختبار لم يُنفذ.

- المسار: `/opt/InstallingDockerDeployment` — البوابة: `INSTALLATION_REPORT.md` (نتائج فعلية).

</div>

---

## 1) تثبيت Docker Engine + Compose (رسمي)
```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 2) تشغيل Docker والتحقق
```bash
sudo systemctl enable docker
sudo systemctl start docker
sudo docker version
sudo docker compose version
sudo docker info
```
(اختياري، مراجعة أمنية — يمنح صلاحيات قوية):
```bash
sudo usermod -aG docker $USER   # ثم أعد تسجيل الدخول
```

## 3) تثبيت Portainer (وصول محلي فقط افتراضيًا)
```bash
docker volume create portainer_data

docker run -d \
  --name portainer \
  --restart=always \
  -p 127.0.0.1:9000:9000 \
  -p 127.0.0.1:9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```
> هذا إعداد **وصول محلي فقط** (لا كشف مباشر للإنترنت). للوصول عن بُعد استخدم SSH tunnel/VPN/جدار ناري مضبوط. الربط مع Traefik لاحقًا (Phase 2، بعد PASS وطلب مستقل).

## 4) روابط/وصول الإدارة
- Portainer محليًا: `https://localhost:9443` (أو عبر نفق SSH: `ssh -L 9443:127.0.0.1:9443 user@server`)
- Docker Engine: خدمة على Ubuntu (`systemctl status docker`)
- Docker Compose: `docker compose ...`

## 5) تحقق وسجّل الأدلة (إلزامي)
```bash
docker version && docker compose version
docker run --rm hello-world
docker ps -a --filter name=portainer
```
حدّث `INSTALLATION_REPORT.md` و`VERSION_INFO.md` بنتائج فعلية. **لا أي ربط/تكامل قبل PASS.**

## سكربتات مساعدة (نفس النطاق، تثبيت فقط)
```bash
cd /opt/InstallingDockerDeployment/01-Installation && chmod +x scripts/*.sh
bash scripts/preflight.sh
bash scripts/install-ubuntu.sh all   # افتراضي Portainer محلي 127.0.0.1
bash scripts/verify.sh
```