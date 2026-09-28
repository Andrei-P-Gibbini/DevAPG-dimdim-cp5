-- =====================================================================
-- DimDim CP5 - Script de banco (Azure SQL Database)
-- Modelo master-detail: Clientes (1) ---- (N) Transacoes
-- =====================================================================

IF OBJECT_ID('dbo.Transacoes', 'U') IS NOT NULL DROP TABLE dbo.Transacoes;
IF OBJECT_ID('dbo.Clientes',   'U') IS NOT NULL DROP TABLE dbo.Clientes;
GO

-- MASTER
CREATE TABLE dbo.Clientes (
    Id            INT           IDENTITY(1,1) NOT NULL,
    Nome          NVARCHAR(100) NOT NULL,
    Email         NVARCHAR(150) NOT NULL,
    DataCadastro  DATETIME2     NOT NULL CONSTRAINT DF_Clientes_DataCadastro DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Clientes       PRIMARY KEY (Id),
    CONSTRAINT UQ_Clientes_Email UNIQUE (Email)
);
GO

-- DETAIL
CREATE TABLE dbo.Transacoes (
    Id             INT           IDENTITY(1,1) NOT NULL,
    ClienteId      INT           NOT NULL,
    Tipo           NVARCHAR(20)  NOT NULL,
    Valor          DECIMAL(18,2) NOT NULL,
    Descricao      NVARCHAR(200) NULL,
    DataTransacao  DATETIME2     NOT NULL CONSTRAINT DF_Transacoes_Data DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Transacoes          PRIMARY KEY (Id),
    CONSTRAINT CK_Transacoes_Tipo     CHECK (Tipo IN ('DEPOSITO', 'SAQUE', 'PIX')),
    CONSTRAINT CK_Transacoes_Valor    CHECK (Valor > 0),
    CONSTRAINT FK_Transacoes_Clientes FOREIGN KEY (ClienteId)
        REFERENCES dbo.Clientes (Id) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Transacoes_ClienteId ON dbo.Transacoes (ClienteId);
GO
