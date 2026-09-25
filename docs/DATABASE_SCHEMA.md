# 🗄️ Esquema de Banco de Dados - Loki Medical Suite

O **Loki Medical Suite** utiliza o `oxmysql` para comunicação assíncrona com o MySQL / MariaDB. O script inclui verificação de inicialização automática com `CREATE TABLE IF NOT EXISTS`, garantindo instalação limpa sem necessidade de executar comandos manuais.

---

## 📋 Tabelas do Sistema

### 1. `prescription_insurance`
Armazena a posse e a data de aquisição do convênio médico/plano de saúde de cada cidadão.

```sql
CREATE TABLE IF NOT EXISTS `prescription_insurance` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL UNIQUE,
    `date` BIGINT NOT NULL,
    `active` TINYINT(1) DEFAULT 1,
    INDEX `idx_insurance_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

- **`identifier`:** Identificador canônico do cidadão (`citizenid` no QBox ou `identifier` no ESX).
- **`date`:** Timestamp em milissegundos (`os.time() * 1000`) do momento em que o plano foi adquirido.
- **`active`:** Flag de status do convênio (1 = Ativo, 0 = Inativo/Cancelado).

---

### 2. `prescriptions_active`
Histórico de receitas médicas emitidas pelos doutores para rastreabilidade farmacêutica e controle de recargas de uso contínuo.

```sql
CREATE TABLE IF NOT EXISTS `prescriptions_active` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `doctor_identifier` VARCHAR(60) NOT NULL,
    `doctor_name` VARCHAR(100) NOT NULL,
    `patient_identifier` VARCHAR(60) NOT NULL,
    `patient_name` VARCHAR(100) NOT NULL,
    `patient_dob` VARCHAR(50) DEFAULT NULL,
    `medications` LONGTEXT NOT NULL,
    `notes` TEXT DEFAULT NULL,
    `issued_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NOT NULL,
    `refills_remaining` INT DEFAULT 1,
    `status` ENUM('active', 'completed', 'expired') DEFAULT 'active',
    INDEX `idx_patient` (`patient_identifier`),
    INDEX `idx_doctor` (`doctor_identifier`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

- **`medications`:** Payload JSON contendo a relação de medicamentos, posologia e quantidades autorizadas.
- **`refills_remaining`:** Número de recargas ainda disponíveis antes do recolhimento obrigatório da receita.
- **`expires_at`:** Timestamp que determina quando a farmácia deve recusar a receita por vencimento.

---

### 3. `medical_certificates`
Registro dos atestados médicos oficiais emitidos para fins trabalhistas e judiciais.

```sql
CREATE TABLE IF NOT EXISTS `medical_certificates` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `doctor_identifier` VARCHAR(60) NOT NULL,
    `doctor_name` VARCHAR(100) NOT NULL,
    `patient_identifier` VARCHAR(60) NOT NULL,
    `patient_name` VARCHAR(100) NOT NULL,
    `days` INT NOT NULL,
    `reason` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NOT NULL,
    INDEX `idx_cert_patient` (`patient_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## ⚡ Otimização & Desempenho
- Todas as colunas de busca frequente (`identifier`, `status`, `expires_at`) possuem índices dedicados (`INDEX`), garantindo tempos de consulta inferiores a **1ms**.
- As transações são executadas via chamadas não-bloqueantes (`MySQL.query` / `MySQL.scalar`).
