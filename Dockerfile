# ─────────────────────────────────────────────────────────────────────────────
# WSO2 MICRO INTEGRATOR (MI) - DEVELOPER DOCKERFILE
# ─────────────────────────────────────────────────────────────────────────────

# Menggunakan base image resmi WSO2 MI
FROM wso2/wso2mi:4.2.0

LABEL maintainer="Telco OMS Developer Team"
LABEL description="HelloWorld Integration service bundled into WSO2 MI runtime"

# Menyalin file .car hasil compile dari folder target developer ke folder deployment WSO2 MI
# Folder 'carbonapps' adalah hot-deployment folder di mana WSO2 MI membaca semua berkas integrasi XML
COPY HelloWorldCompositeExporter_1.0.0.car /home/wso2carbon/wso2mi-4.2.0/repository/deployment/server/carbonapps/

# Port WSO2 MI default:
# - 8290: HTTP Pass-through (akses API Utama)
# - 8253: HTTPS Pass-through
# - 9164: Management/Metrics API
EXPOSE 8290 8253 9164
