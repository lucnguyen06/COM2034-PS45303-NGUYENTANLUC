USE QLNHATRO;
GO
IF OBJECT_ID(N'dbo.usp_ThemNguoiDung', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_ThemNguoiDung;
GO
CREATE PROCEDURE dbo.usp_ThemNguoiDung
    @HoTen nvarchar(max) = NULL, @GioiTinh nvarchar(max) = NULL,
    @DienThoai varchar(max) = NULL, @SoNha nvarchar(max) = NULL,
    @Duong nvarchar(max) = NULL, @Phuong nvarchar(max) = NULL,
    @Quan nvarchar(max) = NULL, @Email varchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@HoTen)), N'') IS NULL OR @GioiTinh IS NULL
        OR @DienThoai IS NULL OR NULLIF(LTRIM(RTRIM(@SoNha)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Duong)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Phuong)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Quan)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Email)), '') IS NULL
    BEGIN
        PRINT N'Vui lòng nhập đầy đủ thông tin người dùng.';
        RETURN 1;
    END;
    IF DATALENGTH(@HoTen) > 120 OR DATALENGTH(@GioiTinh) <> 2
        OR @GioiTinh COLLATE Latin1_General_BIN2 NOT IN (N'M', N'F')
        OR DATALENGTH(@DienThoai) NOT BETWEEN 10 AND 15
        OR DATALENGTH(@DienThoai) <> LEN(@DienThoai)
        OR @DienThoai COLLATE Latin1_General_BIN2 LIKE '%[^0-9]%'
        OR DATALENGTH(@SoNha) > 30 OR DATALENGTH(@Duong) > 160
        OR DATALENGTH(@Phuong) > 100 OR DATALENGTH(@Quan) > 80 OR DATALENGTH(@Email) > 120
        OR @Email NOT LIKE '%_@_%._%' OR @Email LIKE '% %' OR @Email LIKE '%@%@%'
    BEGIN
        PRINT N'Họ tên, địa chỉ, giới tính, điện thoại hoặc email không hợp lệ.';
        RETURN 2;
    END;
    BEGIN TRY
        INSERT dbo.NGUOIDUNG (HoTen, GioiTinh, DienThoai, SoNha, Duong, Phuong, Quan, Email)
        VALUES (@HoTen, @GioiTinh, @DienThoai, @SoNha, @Duong, @Phuong, @Quan, @Email);
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            PRINT N'Email đã được sử dụng.';
        ELSE
            PRINT ERROR_MESSAGE();
        RETURN 3;
    END CATCH;
END;
GO
IF OBJECT_ID(N'dbo.usp_ThemNhaTro', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_ThemNhaTro;
GO
CREATE PROCEDURE dbo.usp_ThemNhaTro
    @MaLoai int = NULL, @DienTich decimal(12,4) = NULL, @Gia int = NULL,
    @SoNha nvarchar(max) = NULL, @Duong nvarchar(max) = NULL, @Phuong nvarchar(max) = NULL,
    @Quan nvarchar(max) = NULL, @MoTa nvarchar(max) = NULL,
    @NgayDang date = NULL, @MaLienHe int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @MaLoai IS NULL OR @DienTich IS NULL OR @Gia IS NULL OR @NgayDang IS NULL OR @MaLienHe IS NULL
        OR NULLIF(LTRIM(RTRIM(@SoNha)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Duong)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Phuong)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Quan)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@MoTa)), N'') IS NULL
    BEGIN
        PRINT N'Vui lòng nhập đầy đủ thông tin nhà trọ.';
        RETURN 1;
    END;
    IF @DienTich NOT BETWEEN 0.01 AND 9999.99 OR @DienTich <> ROUND(@DienTich, 2)
        OR @Gia <= 0 OR @MaLoai NOT BETWEEN 1 AND 255 OR @MaLienHe <= 0
        OR DATALENGTH(@SoNha) > 30 OR DATALENGTH(@Duong) > 160
        OR DATALENGTH(@Phuong) > 100 OR DATALENGTH(@Quan) > 80 OR DATALENGTH(@MoTa) > 1000
    BEGIN
        PRINT N'Diện tích, giá, địa chỉ, mô tả hoặc mã liên kết không hợp lệ.';
        RETURN 2;
    END;
    BEGIN TRY
        INSERT dbo.NHATRO (MaLoai, DienTich, Gia, SoNha, Duong, Phuong, Quan, MoTa, NgayDang, MaLienHe)
        VALUES (@MaLoai, @DienTich, @Gia, @SoNha, @Duong, @Phuong, @Quan, @MoTa, @NgayDang, @MaLienHe);
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 547
            PRINT N'Loại nhà hoặc người liên hệ không tồn tại.';
        ELSE
            PRINT ERROR_MESSAGE();
        RETURN 3;
    END CATCH;
END;
GO
IF OBJECT_ID(N'dbo.usp_ThemDanhGia', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_ThemDanhGia;
GO
CREATE PROCEDURE dbo.usp_ThemDanhGia
    @MaNhaTro int = NULL, @MaND int = NULL,
    @TrangThai varchar(max) = NULL, @NoiDung nvarchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @MaNhaTro IS NULL OR @MaND IS NULL OR NULLIF(LTRIM(RTRIM(@TrangThai)), '') IS NULL
    BEGIN
        PRINT N'Vui lòng nhập mã nhà trọ, mã người đánh giá và trạng thái.';
        RETURN 1;
    END;
    IF @MaNhaTro <= 0 OR @MaND <= 0 OR DATALENGTH(@TrangThai) <> LEN(@TrangThai)
        OR @TrangThai COLLATE Latin1_General_BIN2 NOT IN ('LIKE', 'DISLIKE')
        OR DATALENGTH(@NoiDung) > 1000 OR LTRIM(RTRIM(@NoiDung)) = N''
    BEGIN
        PRINT N'Mã, trạng thái hoặc nội dung đánh giá không hợp lệ.';
        RETURN 2;
    END;
    BEGIN TRY
        INSERT dbo.DANHGIA (MaNhaTro, MaND, TrangThai, NoiDung)
        VALUES (@MaNhaTro, @MaND, @TrangThai, @NoiDung);
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            PRINT N'Người dùng đã đánh giá nhà trọ này.';
        ELSE IF ERROR_NUMBER() = 547
            PRINT N'Nhà trọ hoặc người đánh giá không tồn tại.';
        ELSE
            PRINT ERROR_MESSAGE();
        RETURN 3;
    END CATCH;
END;
GO
IF OBJECT_ID(N'dbo.usp_TimNhaTro', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_TimNhaTro;
GO
CREATE PROCEDURE dbo.usp_TimNhaTro
    @Quan nvarchar(40) = NULL, @DienTichTu decimal(6,2) = NULL, @DienTichDen decimal(6,2) = NULL,
    @NgayTu date = NULL, @NgayDen date = NULL, @GiaTu int = NULL, @GiaDen int = NULL,
    @MaLoai tinyint = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @DienTichTu > @DienTichDen OR @NgayTu > @NgayDen OR @GiaTu > @GiaDen
        OR @DienTichTu < 0 OR @DienTichDen < 0 OR @GiaTu < 0 OR @GiaDen < 0
    BEGIN
        PRINT N'Khoảng diện tích, ngày đăng hoặc giá không hợp lệ.';
        RETURN 1;
    END;
    SELECT N'Cho thuê phòng trọ tại ' + nt.SoNha + N' ' + nt.Duong + N', ' + nt.Phuong + N', ' + nt.Quan AS DiaChiNhaTro,
           REPLACE(REPLACE(REPLACE(
               LEFT(f.DienTichGoc, LEN(f.DienTichGoc) - CASE
                   WHEN RIGHT(f.DienTichGoc, 3) = '.00' THEN 3
                   WHEN RIGHT(f.DienTichGoc, 1) = '0' THEN 1 ELSE 0 END),
               ',', '#'), '.', ','), '#', '.') + ' m2' AS DienTich,
           REPLACE(REPLACE(CONVERT(varchar(30), CONVERT(money, nt.Gia), 1), '.00', ''), ',', '.') AS Gia,
           nt.MoTa, CONVERT(char(10), nt.NgayDang, 105) AS NgayDang,
           CASE nd.GioiTinh WHEN N'M' THEN N'A. ' ELSE N'C. ' END + nd.HoTen AS NguoiLienHe,
           nd.DienThoai,
           nd.SoNha + N' ' + nd.Duong + N', ' + nd.Phuong + N', ' + nd.Quan AS DiaChiLienHe
    FROM dbo.NHATRO AS nt
    JOIN dbo.NGUOIDUNG AS nd ON nd.MaND = nt.MaLienHe
    CROSS APPLY (SELECT CONVERT(varchar(30), CONVERT(money, nt.DienTich), 1) AS DienTichGoc) AS f
    WHERE (@Quan IS NULL OR nt.Quan = @Quan)
      AND (@MaLoai IS NULL OR nt.MaLoai = @MaLoai)
      AND (@DienTichTu IS NULL OR nt.DienTich >= @DienTichTu)
      AND (@DienTichDen IS NULL OR nt.DienTich <= @DienTichDen)
      AND (@NgayTu IS NULL OR nt.NgayDang >= @NgayTu)
      AND (@NgayDen IS NULL OR nt.NgayDang <= @NgayDen)
      AND (@GiaTu IS NULL OR nt.Gia >= @GiaTu)
      AND (@GiaDen IS NULL OR nt.Gia <= @GiaDen)
    ORDER BY nt.NgayDang DESC, nt.MaNhaTro
    OPTION (RECOMPILE);
END;
GO
IF OBJECT_ID(N'dbo.fn_MaNguoiDung', N'FN') IS NOT NULL DROP FUNCTION dbo.fn_MaNguoiDung;
GO
CREATE FUNCTION dbo.fn_MaNguoiDung (
    @MaND int, @HoTen nvarchar(60), @GioiTinh nchar(1), @DienThoai varchar(15),
    @SoNha nvarchar(15), @Duong nvarchar(80), @Phuong nvarchar(50), @Quan nvarchar(40), @Email varchar(120)
)
RETURNS int
AS
BEGIN
    DECLARE @KetQua int;
    SELECT @KetQua = MaND
    FROM dbo.NGUOIDUNG
    WHERE (@MaND IS NULL OR MaND = @MaND)
      AND HoTen = @HoTen AND GioiTinh = @GioiTinh AND DienThoai = @DienThoai
      AND SoNha = @SoNha AND Duong = @Duong AND Phuong = @Phuong AND Quan = @Quan AND Email = @Email;
    RETURN @KetQua;
END;
GO
IF OBJECT_ID(N'dbo.fn_DemDanhGia', N'IF') IS NOT NULL DROP FUNCTION dbo.fn_DemDanhGia;
GO
CREATE FUNCTION dbo.fn_DemDanhGia (@MaNhaTro int)
RETURNS TABLE
AS
RETURN (
    SELECT COUNT_BIG(CASE WHEN TrangThai = 'LIKE' THEN 1 END) AS TongLike,
           COUNT_BIG(CASE WHEN TrangThai = 'DISLIKE' THEN 1 END) AS TongDislike
    FROM dbo.DANHGIA
    WHERE MaNhaTro = @MaNhaTro
);
GO
IF OBJECT_ID(N'dbo.vw_Top10NhaTro', N'V') IS NOT NULL DROP VIEW dbo.vw_Top10NhaTro;
GO
CREATE VIEW dbo.vw_Top10NhaTro
AS
SELECT TOP (10) nt.MaNhaTro, nt.DienTich, nt.Gia, nt.MoTa, nt.NgayDang,
       nd.HoTen AS NguoiLienHe,
       nt.SoNha + N' ' + nt.Duong + N', ' + nt.Phuong + N', ' + nt.Quan AS DiaChiNhaTro,
       nd.SoNha + N' ' + nd.Duong + N', ' + nd.Phuong + N', ' + nd.Quan AS DiaChiLienHe,
       nd.DienThoai, nd.Email, ISNULL(l.TongLike, 0) AS TongLike
FROM dbo.NHATRO AS nt
JOIN dbo.NGUOIDUNG AS nd ON nd.MaND = nt.MaLienHe
LEFT JOIN (
    SELECT MaNhaTro, COUNT_BIG(*) AS TongLike
    FROM dbo.DANHGIA
    WHERE TrangThai = 'LIKE'
    GROUP BY MaNhaTro
) AS l ON l.MaNhaTro = nt.MaNhaTro
ORDER BY ISNULL(l.TongLike, 0) DESC, nt.MaNhaTro ASC;
GO
IF OBJECT_ID(N'dbo.usp_XemDanhGia', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_XemDanhGia;
GO
CREATE PROCEDURE dbo.usp_XemDanhGia @MaNhaTro int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @MaNhaTro IS NULL OR @MaNhaTro <= 0
    BEGIN
        PRINT N'Vui lòng nhập mã nhà trọ hợp lệ.';
        RETURN 1;
    END;
    SELECT dg.MaNhaTro, nd.HoTen AS NguoiDanhGia, dg.TrangThai, dg.NoiDung
    FROM dbo.DANHGIA AS dg
    JOIN dbo.NGUOIDUNG AS nd ON nd.MaND = dg.MaND
    WHERE dg.MaNhaTro = @MaNhaTro
    ORDER BY dg.MaND;
END;
GO
IF OBJECT_ID(N'dbo.usp_XoaNhaTroTheoDislike', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_XoaNhaTroTheoDislike;
GO
CREATE PROCEDURE dbo.usp_XoaNhaTroTheoDislike @SoDislike int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @SoDislike IS NULL OR @SoDislike < 0
    BEGIN
        PRINT N'Vui lòng nhập ngưỡng DISLIKE không âm.';
        RETURN 1;
    END;

    DECLARE @TuMoGiaoDich bit = CASE WHEN @@TRANCOUNT = 0 THEN 1 ELSE 0 END;
    DECLARE @DanhSach TABLE (MaNhaTro int PRIMARY KEY);
    DECLARE @SoNhaTroDaXoa int;
    BEGIN TRY
        IF @TuMoGiaoDich = 1 BEGIN TRANSACTION;
        ELSE SAVE TRANSACTION XoaTheoDislike;

        INSERT @DanhSach (MaNhaTro)
        SELECT nt.MaNhaTro
        FROM dbo.NHATRO AS nt WITH (XLOCK)
        JOIN (
            SELECT MaNhaTro
            FROM dbo.DANHGIA WITH (UPDLOCK, HOLDLOCK)
            WHERE TrangThai = 'DISLIKE'
            GROUP BY MaNhaTro
            HAVING COUNT_BIG(*) > @SoDislike
        ) AS d ON d.MaNhaTro = nt.MaNhaTro;

        DELETE dg FROM dbo.DANHGIA AS dg JOIN @DanhSach AS ds ON ds.MaNhaTro = dg.MaNhaTro;
        DELETE nt FROM dbo.NHATRO AS nt JOIN @DanhSach AS ds ON ds.MaNhaTro = nt.MaNhaTro;
        SET @SoNhaTroDaXoa = @@ROWCOUNT;
        IF @TuMoGiaoDich = 1 COMMIT TRANSACTION;
        SELECT @SoNhaTroDaXoa AS SoNhaTroDaXoa;
    END TRY
    BEGIN CATCH
        IF @TuMoGiaoDich = 1 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        ELSE IF @TuMoGiaoDich = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION XoaTheoDislike;
        DECLARE @Loi nvarchar(2048) = ERROR_MESSAGE();
        RAISERROR(N'%s', 16, 1, @Loi);
        RETURN 2;
    END CATCH;
END;
GO
IF OBJECT_ID(N'dbo.usp_XoaNhaTroTheoNgay', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_XoaNhaTroTheoNgay;
GO
CREATE PROCEDURE dbo.usp_XoaNhaTroTheoNgay @NgayTu date = NULL, @NgayDen date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @NgayTu IS NULL OR @NgayDen IS NULL OR @NgayTu > @NgayDen
    BEGIN
        PRINT N'Vui lòng nhập khoảng ngày đăng hợp lệ.';
        RETURN 1;
    END;

    DECLARE @TuMoGiaoDich bit = CASE WHEN @@TRANCOUNT = 0 THEN 1 ELSE 0 END;
    DECLARE @DanhSach TABLE (MaNhaTro int PRIMARY KEY);
    DECLARE @SoNhaTroDaXoa int;
    BEGIN TRY
        IF @TuMoGiaoDich = 1 BEGIN TRANSACTION;
        ELSE SAVE TRANSACTION XoaTheoNgay;

        INSERT @DanhSach (MaNhaTro)
        SELECT MaNhaTro
        FROM dbo.NHATRO WITH (XLOCK, HOLDLOCK)
        WHERE NgayDang BETWEEN @NgayTu AND @NgayDen;

        DELETE dg FROM dbo.DANHGIA AS dg JOIN @DanhSach AS ds ON ds.MaNhaTro = dg.MaNhaTro;
        DELETE nt FROM dbo.NHATRO AS nt JOIN @DanhSach AS ds ON ds.MaNhaTro = nt.MaNhaTro;
        SET @SoNhaTroDaXoa = @@ROWCOUNT;
        IF @TuMoGiaoDich = 1 COMMIT TRANSACTION;
        SELECT @SoNhaTroDaXoa AS SoNhaTroDaXoa;
    END TRY
    BEGIN CATCH
        IF @TuMoGiaoDich = 1 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        ELSE IF @TuMoGiaoDich = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION XoaTheoNgay;
        DECLARE @Loi nvarchar(2048) = ERROR_MESSAGE();
        RAISERROR(N'%s', 16, 1, @Loi);
        RETURN 2;
    END CATCH;
END;
GO
