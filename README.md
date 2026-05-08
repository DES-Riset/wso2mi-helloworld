# 🚀 WSO2 Micro Integrator - Developer Sample Repo (`mi-hello-world`)

Repository ini adalah cetak biru (**sample project**) untuk **Developer Integrasi**. Di sinilah tempat developer menulis kode integrasi, menguji secara lokal, dan mengompilasi artefak menjadi berkas `.car` (Composite Application Archive) sebelum dideploy ke server produksi.

---

## 🏗️ Pembagian Peran Repository (Separation of Concerns)

Untuk menjaga kebersihan dan keamanan level enterprise, kita memisahkan repository menjadi dua bagian utama:

```text
📁 D:/Dedi/wso2/
├── 📁 wso2-server (REPO UTAMA SERVER - OPER DevOps)
│   ├── docker-compose.yaml -> Menginstal & menjaga runtime (Postgres, Nginx, APIM, IS, MI, ELK)
│   ├── nginx/              -> Keamanan reverse proxy, SSL, dan WAF
│   └── install.sh          -> Bash wizard otomatisasi server
│
└── 📁 mi-hello-world (REPO INTEGRASI - DEVELOPER)
    ├── Dockerfile          -> Membungkus .car hasil coding ke dalam WSO2 MI base image
    └── HelloWorldConfigs/  -> Berisi kode integrasi (Synapse XML) hasil ngoding
        └── src/main/synapse-config/api/HelloWorldAPI.xml  -> Berkas API buatan developer
```

---

## 💻 Cara Developer Ngoding Integrasi

Developer menggunakan **VS Code (dengan WSO2 Extension)** atau **WSO2 Integration Studio** untuk menulis skenario integrasi (menggunakan bahasa Synapse XML bawaan WSO2).

### 1. Struktur Folder Synapse XML Utama
- **`api/`**: Tempat menulis REST API endpoints (seperti [HelloWorldAPI.xml](file:///D:/Dedi/wso2/mi-hello-world/HelloWorldConfigs/src/main/synapse-config/api/HelloWorldAPI.xml)).
- **`proxy-services/`**: Layanan proxy SOAP/REST untuk integrasi legacy system.
- **`endpoints/`**: Definisi URL backend (seperti Mock CRM atau Mock OSS).
- **`sequences/`**: Sekumpulan instruksi/mediator pemrosesan data yang reusable.

### 2. Proses Build & Packaging (Menjadi `.car` File)
WSO2 menggunakan sistem build berbasis **Apache Maven**. 
Saat developer selesai mengode, mereka menjalankan perintah berikut di terminal komputer mereka untuk mem-package kode integrasi menjadi sebuah berkas tunggal berformat `.car`:

```bash
mvn clean install
```

Perintah di atas akan menghasilkan berkas bernama **`HelloWorldCompositeExporter_1.0.0.car`** di folder target. Berkas `.car` ini berisi seluruh konfigurasi integrasi XML buatan developer yang siap dijalankan oleh server runtime.

---

## 🚀 Alur Deployment dari Developer ke Server Produksi

Terdapat dua cara untuk men-deploy hasil coding developer ke server infrastruktur `wso2-server`:

### Opsi A: Melalui Docker Image Builder (Sangat Direkomendasikan untuk CI/CD)
1. Developer meng-upload kode ke git branch `main`.
2. Pipeline CI/CD (GitHub Actions / Jenkins) melakukan compile Maven untuk menghasilkan berkas `.car`.
3. Pipeline menjalankan perintah build image menggunakan [Dockerfile](file:///D:/Dedi/wso2/mi-hello-world/Dockerfile) yang ada di repo ini:
   ```bash
   docker build -t deshub-registry/mi-hello-world:1.0.0 .
   ```
4. Image baru di-push ke Docker Registry, lalu Docker Compose di server melakukan rolling update kontainer `micro-integrator`.

### Opsi B: Mount Direktori Lokal (Mudah untuk Tahap Dev/Staging)
Jika ingin melakukan deployment instan tanpa membangun ulang docker image, developer cukup menyalin file `.car` langsung ke folder logis server:
- Salin berkas `HelloWorldCompositeExporter_1.0.0.car` ke direktori bersama di server: `/opt/docker/wso2/carbonapps/`.
- Kontainer WSO2 MI akan langsung mendeteksi berkas baru tersebut secara otomatis (*Hot Deployment*) tanpa perlu merestart kontainer Docker!

---

## 🔒 Konfigurasi Cloudflare Tunnel (Zero Trust) dengan Nginx

Seperti didiskusikan sebelumnya, arsitektur terbaik adalah menggabungkan **Cloudflare Tunnel** dengan **Nginx**:

```text
[ Client (Internet) ] 
       │ (panggil https://gateway.deshub.my.id)
       ▼
[ Cloudflare Edge ] 
       │ (melewati enkripsi Cloudflare Network)
       ▼
[ Cloudflare Tunnel Client (cloudflared) ] ── (mengirim traffic lokal ke port 80/443) ──► [ Nginx ]
                                                                                              │
                                                                    ┌─────────────────────────┴────────────────────────┐
                                                                    ▼ (proxy-net)                                      ▼ (proxy-net)
                                                          [ API Gateway (:8243) ]                            [ Identity Server (:9445) ]
```

1. **Di Dashboard Cloudflare Zero Trust**:
   - Buat satu tunnel baru bernama `deshub-tunnel`.
   - Di bagian **Public Hostname**, tambahkan rute wildcard:
     - Subdomain: `*`
     - Domain: `deshub.my.id`
     - Service Type: `HTTPS` (atau `HTTP`)
     - URL: `localhost:443` (atau `localhost:80` jika SSL ditangani tunnel)
2. **Hasil Akhir**: 
   Semua request subdomain (`is.deshub.my.id`, `gateway.deshub.my.id`, dll.) akan masuk secara otomatis lewat satu pintu di Nginx. Nginx kemudian meneruskan request tersebut secara lokal dan instan ke container yang tepat, membuat sistem Anda bersih, aman, hemat resource, dan sangat mudah dipelihara!
