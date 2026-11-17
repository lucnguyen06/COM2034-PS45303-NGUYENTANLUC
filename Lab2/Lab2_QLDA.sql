    USE master;
    GO
    IF DB_ID(N'QLDA') IS NULL
        EXEC(N'CREATE DATABASE QLDA;');
    GO
    USE QLDA;
    GO
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF OBJECT_ID(N'dbo.NHANVIEN') IS NOT NULL
    OR OBJECT_ID(N'dbo.PHONGBAN') IS NOT NULL
    OR OBJECT_ID(N'dbo.DIADIEM_PHG') IS NOT NULL
    OR OBJECT_ID(N'dbo.THANNHAN') IS NOT NULL
    OR OBJECT_ID(N'dbo.DEAN') IS NOT NULL
    OR OBJECT_ID(N'dbo.CONGVIEC') IS NOT NULL
    OR OBJECT_ID(N'dbo.PHANCONG') IS NOT NULL
    BEGIN
        ;THROW 50001, N'QLDA đã có bảng của bài tập. Để chạy lại Bài 2, chọn riêng phần Bài 2 rồi nhấn F5. Script không xóa dữ liệu có sẵn.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE dbo.NHANVIEN
        (
            HONV    NVARCHAR(15) NOT NULL,
            TENLOT  NVARCHAR(15) NOT NULL,
            TENNV   NVARCHAR(15) NOT NULL,
            MANV    NVARCHAR(9)  NOT NULL,
            NGSINH  DATETIME     NOT NULL,
            DCHI    NVARCHAR(30) NOT NULL,
            PHAI    NVARCHAR(3)  NOT NULL,
            LUONG   FLOAT        NOT NULL,
            MA_NQL  NVARCHAR(9)  NULL,
            PHG     INT          NULL,
            CONSTRAINT PK_NHANVIEN PRIMARY KEY (MANV)
        );

        CREATE TABLE dbo.PHONGBAN
        (
            TENPHG      NVARCHAR(15) NOT NULL,
            MAPHG       INT          NOT NULL,
            TRPHG       NVARCHAR(9)  NULL,
            NG_NHANCHUC DATE         NOT NULL,
            CONSTRAINT PK_PHONGBAN PRIMARY KEY (MAPHG)
        );

        CREATE TABLE dbo.DIADIEM_PHG
        (
            MAPHG   INT          NOT NULL,
            DIADIEM NVARCHAR(15) NOT NULL,
            CONSTRAINT PK_DIADIEM_PHG PRIMARY KEY (MAPHG, DIADIEM)
        );

        CREATE TABLE dbo.THANNHAN
        (
            MA_NVIEN NVARCHAR(9)  NOT NULL,
            TENTN    NVARCHAR(15) NOT NULL,
            PHAI     NVARCHAR(3)  NOT NULL,
            NGSINH   DATE         NOT NULL,
            QUANHE   NVARCHAR(15) NOT NULL,
            CONSTRAINT PK_THANNHAN PRIMARY KEY (MA_NVIEN, TENTN)
        );

        CREATE TABLE dbo.DEAN
        (
            TENDEAN  NVARCHAR(15) NOT NULL,
            MADA     INT          NOT NULL,
            DDIEM_DA NVARCHAR(15) NOT NULL,
            PHONG    INT          NULL,
            CONSTRAINT PK_DEAN PRIMARY KEY (MADA)
        );

        CREATE TABLE dbo.CONGVIEC
        (
            MADA          INT          NOT NULL,
            STT           INT          NOT NULL,
            TEN_CONG_VIEC NVARCHAR(50) NOT NULL,
            CONSTRAINT PK_CONGVIEC PRIMARY KEY (MADA, STT)
        );

        CREATE TABLE dbo.PHANCONG
        (
            MA_NVIEN NVARCHAR(9) NOT NULL,
            MADA     INT         NOT NULL,
            STT      INT         NOT NULL,
            THOIGIAN FLOAT       NOT NULL,
            CONSTRAINT PK_PHANCONG PRIMARY KEY (MA_NVIEN, MADA, STT)
        );

        INSERT INTO dbo.NHANVIEN
            (HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
        VALUES
            (N'Đinh',   N'Bá',    N'Tiên',  N'009', '19600211', N'119 Cống Quỳnh, TP HCM',       N'Nam', 30000, N'005', 5),
            (N'Nguyễn', N'Thanh', N'Tùng',  N'005', '19620820', N'222 Nguyễn Văn Cừ, TP HCM',   N'Nam', 40000, N'006', 5),
            (N'Bùi',    N'Ngọc',  N'Hằng',  N'007', '19540311', N'332 Nguyễn Thái Học, TP HCM', N'Nam', 25000, N'001', 4),
            (N'Lê',     N'Quỳnh', N'Như',   N'001', '19670201', N'291 Hồ Văn Huê, TP HCM',      N'Nữ',  43000, N'006', 4),
            (N'Nguyễn', N'Mạnh',  N'Hùng',  N'004', '19670304', N'95 Bà Rịa, Vũng Tàu',         N'Nam', 38000, N'005', 5),
            (N'Trần',   N'Thanh', N'Tâm',   N'003', '19570504', N'34 Mai Thị Lự, TP HCM',       N'Nam', 25000, N'005', 5),
            (N'Trần',   N'Hồng',  N'Quang', N'008', '19670901', N'80 Lê Hồng Phong, TP HCM',    N'Nam', 25000, N'001', 4),
            (N'Phạm',   N'Văn',   N'Vinh',  N'006', '19650101', N'45 Trưng Vương, Hà Nội',      N'Nữ',  55000, NULL,   1);

        INSERT INTO dbo.PHONGBAN (TENPHG, MAPHG, TRPHG, NG_NHANCHUC)
        VALUES
            (N'Nghiên cứu', 5, N'005', '19780522'),
            (N'Điều hành',  4, N'008', '19850101'),
            (N'Quản lý',    1, N'006', '19710619');

        INSERT INTO dbo.DIADIEM_PHG (MAPHG, DIADIEM)
        VALUES
            (1, N'TP HCM'),
            (4, N'Hà Nội'),
            (5, N'TAU'),
            (5, N'NHA TRANG'),
            (5, N'TP HCM');

        INSERT INTO dbo.THANNHAN (MA_NVIEN, TENTN, PHAI, NGSINH, QUANHE)
        VALUES
            (N'005', N'Trinh',  N'Nữ',  '19760405', N'Con gái'),
            (N'005', N'Khang',  N'Nam', '19731025', N'Con trai'),
            (N'005', N'Phương', N'Nữ',  '19480503', N'Vợ chồng'),
            (N'001', N'Minh',   N'Nam', '19320229', N'Vợ chồng'),
            (N'009', N'Tiến',   N'Nam', '19780101', N'Con trai'),
            (N'009', N'Châu',   N'Nữ',  '19781230', N'Con gái'),
            (N'009', N'Phương', N'Nữ',  '19570505', N'Vợ chồng');

        INSERT INTO dbo.DEAN (TENDEAN, MADA, DDIEM_DA, PHONG)
        VALUES
            (N'Sản phẩm X',  1, N'Vũng Tàu',  5),
            (N'Sản phẩm Y',  2, N'Nha Trang', 5),
            (N'Sản phẩm Z',  3, N'TP HCM',    5),
            (N'Tin học hóa', 10, N'Hà Nội',   4),
            (N'Cáp quang',   20, N'TP HCM',   1),
            (N'Đào tạo',     30, N'Hà Nội',   4);

        INSERT INTO dbo.CONGVIEC (MADA, STT, TEN_CONG_VIEC)
        VALUES
            (1,  1, N'Thiết kế sản phẩm X'),
            (1,  2, N'Thử nghiệm sản phẩm X'),
            (2,  1, N'Sản xuất sản phẩm Y'),
            (2,  2, N'Quảng cáo sản phẩm Y'),
            (3,  1, N'Khuyến mãi sản phẩm Z'),
            (10, 1, N'Tin học hóa nhân sự, tiền lương'),
            (10, 2, N'Tin học hóa phòng kinh doanh'),
            (20, 1, N'Lắp đặt cáp quang khu B'),
            (30, 1, N'Đào tạo nhân viên Marketing'),
            (30, 2, N'Đào tạo chuyên viên thiết kế');

        INSERT INTO dbo.PHANCONG (MA_NVIEN, MADA, STT, THOIGIAN)
        VALUES
            (N'009', 1,  1, 32),
            (N'009', 2,  2, 8),
            (N'004', 3,  1, 40),
            (N'003', 1,  2, 20.0),
            (N'003', 2,  1, 20.0),
            (N'008', 10, 1, 35),
            (N'008', 30, 2, 5),
            (N'001', 30, 1, 20),
            (N'001', 20, 1, 15),
            (N'006', 20, 1, 30),
            (N'005', 3,  1, 10),
            (N'005', 10, 2, 10),
            (N'005', 20, 1, 10),
            (N'007', 30, 2, 30),
            (N'007', 10, 2, 10);

        ALTER TABLE dbo.NHANVIEN WITH CHECK ADD
            CONSTRAINT FK_NHANVIEN_NGUOIQUANLY FOREIGN KEY (MA_NQL)
                REFERENCES dbo.NHANVIEN (MANV),
            CONSTRAINT FK_NHANVIEN_PHONGBAN FOREIGN KEY (PHG)
                REFERENCES dbo.PHONGBAN (MAPHG);

        ALTER TABLE dbo.PHONGBAN WITH CHECK ADD
            CONSTRAINT FK_PHONGBAN_TRUONGPHONG FOREIGN KEY (TRPHG)
                REFERENCES dbo.NHANVIEN (MANV);

        ALTER TABLE dbo.DIADIEM_PHG WITH CHECK ADD
            CONSTRAINT FK_DIADIEM_PHG_PHONGBAN FOREIGN KEY (MAPHG)
                REFERENCES dbo.PHONGBAN (MAPHG);

        ALTER TABLE dbo.THANNHAN WITH CHECK ADD
            CONSTRAINT FK_THANNHAN_NHANVIEN FOREIGN KEY (MA_NVIEN)
                REFERENCES dbo.NHANVIEN (MANV);

        ALTER TABLE dbo.DEAN WITH CHECK ADD
            CONSTRAINT FK_DEAN_PHONGBAN FOREIGN KEY (PHONG)
                REFERENCES dbo.PHONGBAN (MAPHG);

        ALTER TABLE dbo.CONGVIEC WITH CHECK ADD
            CONSTRAINT FK_CONGVIEC_DEAN FOREIGN KEY (MADA)
                REFERENCES dbo.DEAN (MADA);

        ALTER TABLE dbo.PHANCONG WITH CHECK ADD
            CONSTRAINT FK_PHANCONG_NHANVIEN FOREIGN KEY (MA_NVIEN)
                REFERENCES dbo.NHANVIEN (MANV),
            CONSTRAINT FK_PHANCONG_CONGVIEC FOREIGN KEY (MADA, STT)
                REFERENCES dbo.CONGVIEC (MADA, STT);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT N'NHANVIEN' AS TEN_BANG, COUNT(*) AS SO_DONG FROM dbo.NHANVIEN
    UNION ALL SELECT N'PHONGBAN', COUNT(*) FROM dbo.PHONGBAN
    UNION ALL SELECT N'DIADIEM_PHG', COUNT(*) FROM dbo.DIADIEM_PHG
    UNION ALL SELECT N'THANNHAN', COUNT(*) FROM dbo.THANNHAN
    UNION ALL SELECT N'DEAN', COUNT(*) FROM dbo.DEAN
    UNION ALL SELECT N'CONGVIEC', COUNT(*) FROM dbo.CONGVIEC
    UNION ALL SELECT N'PHANCONG', COUNT(*) FROM dbo.PHANCONG;

    USE QLDA;

    DECLARE @ChieuDai DECIMAL(18, 2) = 10;
    DECLARE @ChieuRong DECIMAL(18, 2) = 5;
    DECLARE @DienTich DECIMAL(37, 4);
    DECLARE @ChuVi DECIMAL(20, 2);

    IF @ChieuDai IS NULL OR @ChieuRong IS NULL
    OR @ChieuDai <= 0 OR @ChieuRong <= 0
    BEGIN
        ;THROW 50002, N'Chiều dài và chiều rộng phải lớn hơn 0.', 1;
    END;

    SET @DienTich = @ChieuDai * @ChieuRong;
    SET @ChuVi = 2 * (@ChieuDai + @ChieuRong);
    SELECT @ChieuDai AS CHIEU_DAI, @ChieuRong AS CHIEU_RONG,
        @DienTich AS DIEN_TICH, @ChuVi AS CHU_VI;

    DECLARE @LuongCaoNhat FLOAT;
    DECLARE @NhanVienLuongCaoNhat TABLE
    (
        MANV NVARCHAR(9), HONV NVARCHAR(15), TENLOT NVARCHAR(15),
        TENNV NVARCHAR(15), LUONG FLOAT
    );

    SELECT @LuongCaoNhat = MAX(LUONG) FROM dbo.NHANVIEN;
    INSERT INTO @NhanVienLuongCaoNhat (MANV, HONV, TENLOT, TENNV, LUONG)
    SELECT MANV, HONV, TENLOT, TENNV, LUONG
    FROM dbo.NHANVIEN
    WHERE LUONG = @LuongCaoNhat;

    SELECT MANV, HONV, TENLOT, TENNV, LUONG
    FROM @NhanVienLuongCaoNhat
    ORDER BY MANV;

    DECLARE @TenPhong NVARCHAR(15) = N'Nghiên cứu';
    DECLARE @LuongTrungBinh FLOAT;
    DECLARE @NhanVienTrenTrungBinh TABLE
    (
        HONV NVARCHAR(15), TENLOT NVARCHAR(15), TENNV NVARCHAR(15)
    );

    SELECT @LuongTrungBinh = AVG(nv.LUONG)
    FROM dbo.NHANVIEN AS nv
    INNER JOIN dbo.PHONGBAN AS pb ON pb.MAPHG = nv.PHG
    WHERE pb.TENPHG = @TenPhong;

    INSERT INTO @NhanVienTrenTrungBinh (HONV, TENLOT, TENNV)
    SELECT HONV, TENLOT, TENNV
    FROM dbo.NHANVIEN
    WHERE LUONG > @LuongTrungBinh;

    SELECT @TenPhong AS PHONG_THAM_CHIEU, @LuongTrungBinh AS LUONG_TRUNG_BINH;
    SELECT HONV, TENLOT, TENNV
    FROM @NhanVienTrenTrungBinh
    ORDER BY HONV, TENLOT, TENNV;

    DECLARE @NguongLuong FLOAT = 30000;
    DECLARE @PhongLuongCao TABLE
    (
        MAPHG INT, TENPHG NVARCHAR(15), SO_NHAN_VIEN INT
    );

    INSERT INTO @PhongLuongCao (MAPHG, TENPHG, SO_NHAN_VIEN)
    SELECT pb.MAPHG, pb.TENPHG, COUNT(nv.MANV)
    FROM dbo.PHONGBAN AS pb
    INNER JOIN dbo.NHANVIEN AS nv ON nv.PHG = pb.MAPHG
    GROUP BY pb.MAPHG, pb.TENPHG
    HAVING AVG(nv.LUONG) > @NguongLuong;

    SELECT TENPHG, SO_NHAN_VIEN
    FROM @PhongLuongCao
    ORDER BY MAPHG;

    DECLARE @ThongKeDeAn TABLE
    (
        MAPHG INT, TENPHG NVARCHAR(15), SO_LUONG_DE_AN INT
    );

    INSERT INTO @ThongKeDeAn (MAPHG, TENPHG, SO_LUONG_DE_AN)
    SELECT pb.MAPHG, pb.TENPHG, COUNT(da.MADA)
    FROM dbo.PHONGBAN AS pb
    LEFT JOIN dbo.DEAN AS da ON da.PHONG = pb.MAPHG
    GROUP BY pb.MAPHG, pb.TENPHG;

    SELECT TENPHG, SO_LUONG_DE_AN
    FROM @ThongKeDeAn
    ORDER BY MAPHG;
