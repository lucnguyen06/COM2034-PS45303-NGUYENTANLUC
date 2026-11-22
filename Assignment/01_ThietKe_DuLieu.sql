USE master;
GO
IF DB_ID(N'QLNHATRO') IS NULL
    CREATE DATABASE QLNHATRO;
GO
USE QLNHATRO;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID(N'dbo.LOAINHA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LOAINHA (
        MaLoai tinyint IDENTITY(1,1) NOT NULL CONSTRAINT PK_LOAINHA PRIMARY KEY,
        TenLoai nvarchar(50) NOT NULL CONSTRAINT UQ_LOAINHA_Ten UNIQUE,
        CONSTRAINT CK_LOAINHA_Ten CHECK (LEN(LTRIM(RTRIM(TenLoai))) > 0)
    );
END;

IF OBJECT_ID(N'dbo.NGUOIDUNG', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NGUOIDUNG (
        MaND int IDENTITY(1,1) NOT NULL CONSTRAINT PK_NGUOIDUNG PRIMARY KEY,
        HoTen nvarchar(60) NOT NULL,
        GioiTinh nchar(1) NOT NULL,
        DienThoai varchar(15) NOT NULL,
        SoNha nvarchar(15) NOT NULL,
        Duong nvarchar(80) NOT NULL,
        Phuong nvarchar(50) NOT NULL,
        Quan nvarchar(40) NOT NULL,
        Email varchar(120) NOT NULL CONSTRAINT UQ_NGUOIDUNG_Email UNIQUE,
        CONSTRAINT CK_NGUOIDUNG_HoTen CHECK (LEN(LTRIM(RTRIM(HoTen))) > 0),
        CONSTRAINT CK_NGUOIDUNG_GioiTinh CHECK (GioiTinh IN (N'M', N'F')),
        CONSTRAINT CK_NGUOIDUNG_DienThoai CHECK (
            LEN(DienThoai) BETWEEN 10 AND 15 AND DATALENGTH(DienThoai) = LEN(DienThoai)
            AND DienThoai COLLATE Latin1_General_BIN2 NOT LIKE '%[^0-9]%'),
        CONSTRAINT CK_NGUOIDUNG_DiaChi CHECK (
            LEN(LTRIM(RTRIM(SoNha))) > 0 AND LEN(LTRIM(RTRIM(Duong))) > 0
            AND LEN(LTRIM(RTRIM(Phuong))) > 0 AND LEN(LTRIM(RTRIM(Quan))) > 0),
        CONSTRAINT CK_NGUOIDUNG_Email CHECK (
            Email LIKE '%_@_%._%' AND Email NOT LIKE '% %' AND Email NOT LIKE '%@%@%')
    );
END;

IF OBJECT_ID(N'dbo.NHATRO', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NHATRO (
        MaNhaTro int IDENTITY(1,1) NOT NULL CONSTRAINT PK_NHATRO PRIMARY KEY,
        MaLoai tinyint NOT NULL CONSTRAINT FK_NHATRO_LOAINHA REFERENCES dbo.LOAINHA(MaLoai),
        DienTich decimal(6,2) NOT NULL,
        Gia int NOT NULL,
        SoNha nvarchar(15) NOT NULL,
        Duong nvarchar(80) NOT NULL,
        Phuong nvarchar(50) NOT NULL,
        Quan nvarchar(40) NOT NULL,
        MoTa nvarchar(500) NOT NULL,
        NgayDang date NOT NULL CONSTRAINT DF_NHATRO_NgayDang DEFAULT (CONVERT(date, GETDATE())),
        MaLienHe int NOT NULL CONSTRAINT FK_NHATRO_NGUOIDUNG REFERENCES dbo.NGUOIDUNG(MaND),
        CONSTRAINT CK_NHATRO_DienTich CHECK (DienTich > 0),
        CONSTRAINT CK_NHATRO_Gia CHECK (Gia > 0),
        CONSTRAINT CK_NHATRO_DiaChi CHECK (
            LEN(LTRIM(RTRIM(SoNha))) > 0 AND LEN(LTRIM(RTRIM(Duong))) > 0
            AND LEN(LTRIM(RTRIM(Phuong))) > 0 AND LEN(LTRIM(RTRIM(Quan))) > 0),
        CONSTRAINT CK_NHATRO_MoTa CHECK (LEN(LTRIM(RTRIM(MoTa))) > 0)
    );
END;

IF OBJECT_ID(N'dbo.DANHGIA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DANHGIA (
        MaNhaTro int NOT NULL CONSTRAINT FK_DANHGIA_NHATRO REFERENCES dbo.NHATRO(MaNhaTro),
        MaND int NOT NULL CONSTRAINT FK_DANHGIA_NGUOIDUNG REFERENCES dbo.NGUOIDUNG(MaND),
        TrangThai varchar(7) NOT NULL,
        NoiDung nvarchar(500) NULL,
        CONSTRAINT PK_DANHGIA PRIMARY KEY (MaNhaTro, MaND),
        CONSTRAINT CK_DANHGIA_TrangThai CHECK (
            TrangThai COLLATE Latin1_General_BIN2 IN ('LIKE', 'DISLIKE')
            AND DATALENGTH(TrangThai) = LEN(TrangThai)),
        CONSTRAINT CK_DANHGIA_NoiDung CHECK (NoiDung IS NULL OR LEN(LTRIM(RTRIM(NoiDung))) > 0)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID(N'dbo.NHATRO', N'U') AND name = N'IX_NHATRO_Quan_Loai_Ngay')
    EXEC sys.sp_executesql N'CREATE INDEX IX_NHATRO_Quan_Loai_Ngay ON dbo.NHATRO(Quan, MaLoai, NgayDang) INCLUDE (DienTich, Gia);';
IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID(N'dbo.NHATRO', N'U') AND name = N'IX_NHATRO_NgayDang')
    EXEC sys.sp_executesql N'CREATE INDEX IX_NHATRO_NgayDang ON dbo.NHATRO(NgayDang);';
IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID(N'dbo.NHATRO', N'U') AND name = N'IX_NHATRO_MaLoai')
    EXEC sys.sp_executesql N'CREATE INDEX IX_NHATRO_MaLoai ON dbo.NHATRO(MaLoai);';
IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID(N'dbo.NHATRO', N'U') AND name = N'IX_NHATRO_MaLienHe')
    EXEC sys.sp_executesql N'CREATE INDEX IX_NHATRO_MaLienHe ON dbo.NHATRO(MaLienHe);';
IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID(N'dbo.DANHGIA', N'U') AND name = N'IX_DANHGIA_TrangThai_NhaTro')
    EXEC sys.sp_executesql N'CREATE INDEX IX_DANHGIA_TrangThai_NhaTro ON dbo.DANHGIA(TrangThai, MaNhaTro);';
IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID(N'dbo.DANHGIA', N'U') AND name = N'IX_DANHGIA_NguoiDung')
    EXEC sys.sp_executesql N'CREATE INDEX IX_DANHGIA_NguoiDung ON dbo.DANHGIA(MaND);';

IF NOT EXISTS (SELECT 1 FROM dbo.LOAINHA) AND NOT EXISTS (SELECT 1 FROM dbo.NGUOIDUNG)
    AND NOT EXISTS (SELECT 1 FROM dbo.NHATRO) AND NOT EXISTS (SELECT 1 FROM dbo.DANHGIA)
BEGIN
    SET IDENTITY_INSERT dbo.LOAINHA ON;
    INSERT dbo.LOAINHA (MaLoai, TenLoai) VALUES
        (1, N'Phòng trọ khép kín'), (2, N'Căn hộ chung cư'), (3, N'Nhà riêng');
    SET IDENTITY_INSERT dbo.LOAINHA OFF;

    SET IDENTITY_INSERT dbo.NGUOIDUNG ON;
    INSERT dbo.NGUOIDUNG (MaND, HoTen, GioiTinh, DienThoai, SoNha, Duong, Phuong, Quan, Email) VALUES
        (1, N'Thắng', N'M', '0900000001', N'12', N'Trần Duy Hưng', N'Trung Hòa', N'Cầu Giấy', 'thang@example.test'),
        (2, N'Lan', N'F', '0900000002', N'35', N'Nguyễn Trãi', N'Thượng Đình', N'Thanh Xuân', 'lan@example.test'),
        (3, N'Minh', N'M', '0900000003', N'18', N'Chùa Láng', N'Láng Thượng', N'Đống Đa', 'minh@example.test'),
        (4, N'Hương', N'F', '0900000004', N'23', N'Bạch Mai', N'Bạch Mai', N'Hai Bà Trưng', 'huong@example.test'),
        (5, N'Nam', N'M', '0900000005', N'50', N'Đội Cấn', N'Đội Cấn', N'Ba Đình', 'nam@example.test'),
        (6, N'Hà', N'F', '0900000006', N'31', N'Xuân La', N'Xuân La', N'Tây Hồ', 'ha@example.test'),
        (7, N'Phong', N'M', '0900000007', N'19', N'Nguyễn Văn Cừ', N'Bồ Đề', N'Long Biên', 'phong@example.test'),
        (8, N'Trang', N'F', '0900000008', N'64', N'Trần Phú', N'Văn Quán', N'Hà Đông', 'trang@example.test'),
        (9, N'Đức', N'M', '0900000009', N'27', N'Phạm Hùng', N'Mỹ Đình 2', N'Nam Từ Liêm', 'duc@example.test'),
        (10, N'Mai', N'F', '0900000010', N'11', N'Hoàng Quốc Việt', N'Nghĩa Đô', N'Cầu Giấy', 'mai@example.test');
    SET IDENTITY_INSERT dbo.NGUOIDUNG OFF;

    SET IDENTITY_INSERT dbo.NHATRO ON;
    INSERT dbo.NHATRO (MaNhaTro, MaLoai, DienTich, Gia, SoNha, Duong, Phuong, Quan, MoTa, NgayDang, MaLienHe) VALUES
        (1, 1, 30.50, 1700000, N'8A', N'Duy Tân', N'Dịch Vọng Hậu', N'Cầu Giấy', N'Có gác lửng và chỗ để xe.', '20261001', 1),
        (2, 2, 55.00, 6500000, N'22', N'Nguyễn Trãi', N'Thượng Đình', N'Thanh Xuân', N'Hai phòng ngủ, gần ga.', '20261003', 2),
        (3, 1, 22.25, 2400000, N'48', N'Chùa Láng', N'Láng Thượng', N'Đống Đa', N'Phòng sáng, có cửa sổ.', '20261005', 3),
        (4, 3, 68.00, 8500000, N'16', N'Bạch Mai', N'Bạch Mai', N'Hai Bà Trưng', N'Nhà hai tầng, ngõ yên tĩnh.', '20261007', 4),
        (5, 1, 18.00, 2000000, N'45', N'Đội Cấn', N'Đội Cấn', N'Ba Đình', N'Phù hợp cho một người.', '20261009', 5),
        (6, 2, 64.00, 7900000, N'60', N'Xuân La', N'Xuân La', N'Tây Hồ', N'Có ban công và thang máy.', '20261011', 6),
        (7, 1, 26.75, 2300000, N'13', N'Nguyễn Văn Cừ', N'Bồ Đề', N'Long Biên', N'Có bếp và vệ sinh riêng.', '20261013', 7),
        (8, 3, 80.00, 9200000, N'75', N'Trần Phú', N'Văn Quán', N'Hà Đông', N'Có sân để xe và ba phòng ngủ.', '20261015', 8),
        (9, 2, 48.50, 5700000, N'32', N'Phạm Hùng', N'Mỹ Đình 2', N'Nam Từ Liêm', N'Căn hộ một phòng ngủ.', '20261017', 9),
        (10, 1, 24.00, 2800000, N'10', N'Hoàng Quốc Việt', N'Nghĩa Đô', N'Cầu Giấy', N'Có điều hòa, gần bến xe buýt.', '20261019', 10),
        (11, 1, 20.00, 2100000, N'41', N'Xuân La', N'Xuân La', N'Tây Hồ', N'Có tủ quần áo và quạt trần.', '20261021', 6);
    SET IDENTITY_INSERT dbo.NHATRO OFF;

    INSERT dbo.DANHGIA (MaNhaTro, MaND, TrangThai, NoiDung) VALUES
        (1, 2, 'LIKE', N'Giá hợp lý.'), (1, 3, 'LIKE', N'Chỗ để xe rộng.'),
        (1, 4, 'LIKE', NULL), (1, 5, 'DISLIKE', N'Ngõ hơi hẹp.'),
        (2, 1, 'LIKE', N'Đi bộ ra ga thuận tiện.'), (2, 3, 'LIKE', N'Phòng thoáng.'),
        (3, 2, 'DISLIKE', N'Buổi tối hơi ồn.'), (3, 4, 'DISLIKE', N'Cầu thang hẹp.'),
        (3, 5, 'LIKE', N'Cửa sổ đón nắng.'), (4, 5, 'LIKE', N'Khu phố yên tĩnh.'),
        (5, 6, 'DISLIKE', N'Phòng hơi nhỏ.'), (6, 7, 'LIKE', N'Ban công thoáng.'),
        (7, 8, 'LIKE', N'Bếp dễ sử dụng.'), (8, 9, 'LIKE', N'Sân rộng.'),
        (9, 10, 'DISLIKE', N'Đường đông vào giờ cao điểm.'),
        (10, 1, 'LIKE', N'Xe buýt thuận tiện.');
END;
COMMIT TRANSACTION;
GO
