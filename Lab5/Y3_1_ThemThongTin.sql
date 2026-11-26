
USE QLNHATRO;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.usp_ThemNguoiDung', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ThemNguoiDung;
GO

CREATE PROCEDURE dbo.usp_ThemNguoiDung
    @HoTen     nvarchar(max) = NULL,
    @GioiTinh  nvarchar(max) = NULL,
    @DienThoai varchar(max)  = NULL,
    @SoNha     nvarchar(max) = NULL,
    @Duong     nvarchar(max) = NULL,
    @Phuong    nvarchar(max) = NULL,
    @Quan      nvarchar(max) = NULL,
    @Email     varchar(max)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@HoTen)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@GioiTinh)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@DienThoai)), '') IS NULL
        OR NULLIF(LTRIM(RTRIM(@SoNha)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Duong)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Phuong)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Quan)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Email)), '') IS NULL
    BEGIN
        PRINT N'Lỗi [NGUOIDUNG]: Vui lòng nhập đầy đủ thông tin bắt buộc (HoTen, GioiTinh, DienThoai, SoNha, Duong, Phuong, Quan, Email).';
        RETURN 1;
    END;

    IF DATALENGTH(@HoTen) > 120
    BEGIN
        PRINT N'Lỗi [NGUOIDUNG]: Họ tên không được vượt quá 60 ký tự.';
        RETURN 2;
    END;

    IF DATALENGTH(@GioiTinh) <> 2
        OR @GioiTinh COLLATE Latin1_General_BIN2 NOT IN (N'M', N'F')
    BEGIN
        PRINT N'Lỗi [NGUOIDUNG]: Giới tính chỉ chấp nhận giá trị M (Nam) hoặc F (Nữ).';
        RETURN 2;
    END;

    IF DATALENGTH(@DienThoai) NOT BETWEEN 10 AND 15
        OR DATALENGTH(@DienThoai) <> LEN(@DienThoai)
        OR @DienThoai COLLATE Latin1_General_BIN2 LIKE '%[^0-9]%'
    BEGIN
        PRINT N'Lỗi [NGUOIDUNG]: Điện thoại phải gồm từ 10 đến 15 chữ số (không chứa khoảng trắng hay ký tự khác).';
        RETURN 2;
    END;

    IF DATALENGTH(@SoNha) > 30
        OR DATALENGTH(@Duong) > 160
        OR DATALENGTH(@Phuong) > 100
        OR DATALENGTH(@Quan) > 80
    BEGIN
        PRINT N'Lỗi [NGUOIDUNG]: Độ dài địa chỉ (Số nhà <= 15, Đường <= 80, Phường <= 50, Quận <= 40 ký tự) không hợp lệ.';
        RETURN 2;
    END;

    IF DATALENGTH(@Email) > 120
        OR @Email NOT LIKE '%_@_%._%'
        OR @Email LIKE '% %'
        OR @Email LIKE '%@%@%'
    BEGIN
        PRINT N'Lỗi [NGUOIDUNG]: Định dạng hoặc độ dài Email (<= 120 ký tự) không hợp lệ.';
        RETURN 2;
    END;

    IF EXISTS (SELECT 1 FROM dbo.NGUOIDUNG WHERE Email = @Email)
    BEGIN
        PRINT N'Lỗi [NGUOIDUNG]: Email đã được sử dụng bởi người dùng khác.';
        RETURN 3;
    END;

    BEGIN TRY
        INSERT INTO dbo.NGUOIDUNG (HoTen, GioiTinh, DienThoai, SoNha, Duong, Phuong, Quan, Email)
        VALUES (@HoTen, @GioiTinh, @DienThoai, @SoNha, @Duong, @Phuong, @Quan, @Email);

        DECLARE @MaNDMoi int = CONVERT(int, SCOPE_IDENTITY());
        PRINT N'Thêm người dùng thành công (MaND = ' + CONVERT(nvarchar(20), @MaNDMoi) + N').';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            PRINT N'Lỗi [NGUOIDUNG]: Email đã được sử dụng.';
        ELSE
            PRINT ERROR_MESSAGE();
        RETURN 3;
    END CATCH;
END;
GO

IF OBJECT_ID(N'dbo.usp_ThemNhaTro', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ThemNhaTro;
GO

CREATE PROCEDURE dbo.usp_ThemNhaTro
    @MaLoai   int           = NULL,
    @DienTich decimal(12,4) = NULL,
    @Gia      int           = NULL,
    @SoNha    nvarchar(max) = NULL,
    @Duong    nvarchar(max) = NULL,
    @Phuong   nvarchar(max) = NULL,
    @Quan     nvarchar(max) = NULL,
    @MoTa     nvarchar(max) = NULL,
    @NgayDang date          = NULL,
    @MaLienHe int           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @MaLoai IS NULL
        OR @DienTich IS NULL
        OR @Gia IS NULL
        OR NULLIF(LTRIM(RTRIM(@SoNha)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Duong)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Phuong)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@Quan)), N'') IS NULL
        OR NULLIF(LTRIM(RTRIM(@MoTa)), N'') IS NULL
        OR @NgayDang IS NULL
        OR @MaLienHe IS NULL
    BEGIN
        PRINT N'Lỗi [NHATRO]: Vui lòng nhập đầy đủ thông tin bắt buộc (MaLoai, DienTich, Gia, SoNha, Duong, Phuong, Quan, MoTa, NgayDang, MaLienHe).';
        RETURN 1;
    END;

    IF @MaLoai NOT BETWEEN 1 AND 255 OR @MaLienHe <= 0
    BEGIN
        PRINT N'Lỗi [NHATRO]: Mã loại nhà (1..255) hoặc mã người liên hệ (> 0) không hợp lệ.';
        RETURN 2;
    END;

    IF @DienTich NOT BETWEEN 0.01 AND 9999.99
        OR @DienTich <> ROUND(@DienTich, 2)
    BEGIN
        PRINT N'Lỗi [NHATRO]: Diện tích phải nằm trong khoảng 0.01 đến 9999.99 m2 (tối đa 2 chữ số thập phân).';
        RETURN 2;
    END;

    IF @Gia <= 0
    BEGIN
        PRINT N'Lỗi [NHATRO]: Giá phòng phải lớn hơn 0.';
        RETURN 2;
    END;

    IF DATALENGTH(@SoNha) > 30
        OR DATALENGTH(@Duong) > 160
        OR DATALENGTH(@Phuong) > 100
        OR DATALENGTH(@Quan) > 80
        OR DATALENGTH(@MoTa) > 1000
    BEGIN
        PRINT N'Lỗi [NHATRO]: Độ dài địa chỉ hoặc mô tả vượt quá giới hạn cho phép.';
        RETURN 2;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.LOAINHA WHERE MaLoai = @MaLoai)
    BEGIN
        PRINT N'Lỗi [NHATRO]: Mã loại nhà không tồn tại trong bảng LOAINHA.';
        RETURN 3;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.NGUOIDUNG WHERE MaND = @MaLienHe)
    BEGIN
        PRINT N'Lỗi [NHATRO]: Mã người liên hệ không tồn tại trong bảng NGUOIDUNG.';
        RETURN 3;
    END;

    BEGIN TRY
        INSERT INTO dbo.NHATRO (MaLoai, DienTich, Gia, SoNha, Duong, Phuong, Quan, MoTa, NgayDang, MaLienHe)
        VALUES (
            CONVERT(tinyint, @MaLoai),
            CONVERT(decimal(6,2), @DienTich),
            @Gia,
            @SoNha,
            @Duong,
            @Phuong,
            @Quan,
            @MoTa,
            @NgayDang,
            @MaLienHe
        );

        DECLARE @MaNhaTroMoi int = CONVERT(int, SCOPE_IDENTITY());
        PRINT N'Thêm thông tin nhà trọ thành công (MaNhaTro = ' + CONVERT(nvarchar(20), @MaNhaTroMoi) + N').';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 547
            PRINT N'Lỗi [NHATRO]: Loại nhà hoặc người liên hệ không tồn tại.';
        ELSE
            PRINT ERROR_MESSAGE();
        RETURN 3;
    END CATCH;
END;
GO

IF OBJECT_ID(N'dbo.usp_ThemDanhGia', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ThemDanhGia;
GO

CREATE PROCEDURE dbo.usp_ThemDanhGia
    @MaNhaTro  int           = NULL,
    @MaND      int           = NULL,
    @TrangThai varchar(max)  = NULL,
    @NoiDung   nvarchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @MaNhaTro IS NULL
        OR @MaND IS NULL
        OR NULLIF(LTRIM(RTRIM(@TrangThai)), '') IS NULL
    BEGIN
        PRINT N'Lỗi [DANHGIA]: Vui lòng nhập đầy đủ thông tin bắt buộc (MaNhaTro, MaND, TrangThai).';
        RETURN 1;
    END;

    IF @MaNhaTro <= 0 OR @MaND <= 0
    BEGIN
        PRINT N'Lỗi [DANHGIA]: Mã nhà trọ và mã người đánh giá phải lớn hơn 0.';
        RETURN 2;
    END;

    IF DATALENGTH(@TrangThai) <> LEN(@TrangThai)
        OR @TrangThai COLLATE Latin1_General_BIN2 NOT IN ('LIKE', 'DISLIKE')
    BEGIN
        PRINT N'Lỗi [DANHGIA]: Trạng thái đánh giá chỉ chấp nhận LIKE hoặc DISLIKE (viết hoa, không khoảng trắng).';
        RETURN 2;
    END;

    IF @NoiDung IS NOT NULL
        AND (DATALENGTH(@NoiDung) > 1000 OR NULLIF(LTRIM(RTRIM(@NoiDung)), N'') IS NULL)
    BEGIN
        PRINT N'Lỗi [DANHGIA]: Nội dung đánh giá nếu nhập phải có nội dung và không vượt quá 500 ký tự.';
        RETURN 2;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.NHATRO WHERE MaNhaTro = @MaNhaTro)
    BEGIN
        PRINT N'Lỗi [DANHGIA]: Nhà trọ không tồn tại trong bảng NHATRO.';
        RETURN 3;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.NGUOIDUNG WHERE MaND = @MaND)
    BEGIN
        PRINT N'Lỗi [DANHGIA]: Người đánh giá không tồn tại trong bảng NGUOIDUNG.';
        RETURN 3;
    END;

    IF EXISTS (SELECT 1 FROM dbo.DANHGIA WHERE MaNhaTro = @MaNhaTro AND MaND = @MaND)
    BEGIN
        PRINT N'Lỗi [DANHGIA]: Người dùng đã đánh giá nhà trọ này trước đó.';
        RETURN 3;
    END;

    BEGIN TRY
        INSERT INTO dbo.DANHGIA (MaNhaTro, MaND, TrangThai, NoiDung)
        VALUES (@MaNhaTro, @MaND, @TrangThai, @NoiDung);

        PRINT N'Thêm đánh giá thành công (MaNhaTro = ' + CONVERT(nvarchar(20), @MaNhaTro)
            + N', MaND = ' + CONVERT(nvarchar(20), @MaND)
            + N', TrangThai = ' + CONVERT(nvarchar(10), @TrangThai) + N').';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            PRINT N'Lỗi [DANHGIA]: Người dùng đã đánh giá nhà trọ này.';
        ELSE IF ERROR_NUMBER() = 547
            PRINT N'Lỗi [DANHGIA]: Nhà trọ hoặc người đánh giá không tồn tại.';
        ELSE
            PRINT ERROR_MESSAGE();
        RETURN 3;
    END CATCH;
END;
GO


SET NOCOUNT ON;

DECLARE @MaNDCu int;
SELECT @MaNDCu = MaND
FROM dbo.NGUOIDUNG
WHERE Email = 'ngoc.y31@example.test';

IF @MaNDCu IS NOT NULL
BEGIN
    DELETE FROM dbo.DANHGIA
    WHERE MaND = @MaNDCu
       OR MaNhaTro IN (SELECT MaNhaTro FROM dbo.NHATRO WHERE MaLienHe = @MaNDCu);

    DELETE FROM dbo.NHATRO
    WHERE MaLienHe = @MaNDCu;

    DELETE FROM dbo.NGUOIDUNG
    WHERE MaND = @MaNDCu;
END;

DECLARE @KQ_ND_OK  int,
        @KQ_ND_ERR int,
        @KQ_NT_OK  int,
        @KQ_NT_ERR int,
        @KQ_DG_OK  int,
        @KQ_DG_ERR int;

DECLARE @MaNDMoi     int,
        @MaNhaTroMoi int,
        @MaNDDanhGia int;

PRINT N'--- 1. Kiểm thử usp_ThemNguoiDung ---';

EXEC @KQ_ND_OK = dbo.usp_ThemNguoiDung
    @HoTen     = N'Nguyễn Bảo Ngọc',
    @GioiTinh  = N'F',
    @DienThoai = '0912345678',
    @SoNha     = N'14',
    @Duong     = N'Duy Tân',
    @Phuong    = N'Dịch Vọng Hậu',
    @Quan      = N'Cầu Giấy',
    @Email     = 'ngoc.y31@example.test';

EXEC @KQ_ND_ERR = dbo.usp_ThemNguoiDung
    @HoTen = N'Nguyễn Thiếu Thông Tin',
    @Email = 'thieu.y31@example.test';

SELECT @MaNDMoi = MaND
FROM dbo.NGUOIDUNG
WHERE Email = 'ngoc.y31@example.test';

PRINT N'--- 2. Kiểm thử usp_ThemNhaTro ---';

EXEC @KQ_NT_OK = dbo.usp_ThemNhaTro
    @MaLoai   = 1,
    @DienTich = 25.50,
    @Gia      = 2600000,
    @SoNha    = N'14',
    @Duong    = N'Duy Tân',
    @Phuong   = N'Dịch Vọng Hậu',
    @Quan     = N'Cầu Giấy',
    @MoTa     = N'Phòng mới xây, có chỗ để xe và vệ sinh riêng.',
    @NgayDang = '20261026',
    @MaLienHe = @MaNDMoi;

EXEC @KQ_NT_ERR = dbo.usp_ThemNhaTro
    @MaLoai   = 1,
    @MaLienHe = @MaNDMoi;

SELECT @MaNhaTroMoi = MAX(MaNhaTro)
FROM dbo.NHATRO
WHERE MaLienHe = @MaNDMoi;

PRINT N'--- 3. Kiểm thử usp_ThemDanhGia ---';

SELECT TOP (1) @MaNDDanhGia = MaND
FROM dbo.NGUOIDUNG
WHERE MaND <> @MaNDMoi
ORDER BY MaND;

IF @MaNDDanhGia IS NULL
    SET @MaNDDanhGia = @MaNDMoi;

EXEC @KQ_DG_OK = dbo.usp_ThemDanhGia
    @MaNhaTro  = @MaNhaTroMoi,
    @MaND      = @MaNDDanhGia,
    @TrangThai = 'LIKE',
    @NoiDung   = N'Nhà sạch sẽ, an ninh tốt, dễ tìm.';

EXEC @KQ_DG_ERR = dbo.usp_ThemDanhGia
    @MaNhaTro = @MaNhaTroMoi,
    @MaND     = @MaNDDanhGia;


IF @KQ_ND_OK <> 0 OR @KQ_ND_ERR <> 1
    OR @KQ_NT_OK <> 0 OR @KQ_NT_ERR <> 1
    OR @KQ_DG_OK <> 0 OR @KQ_DG_ERR <> 1
BEGIN
    RAISERROR(N'Kết quả kiểm thử Y3.1 không khớp mã trả về kỳ vọng (0, 1, 0, 1, 0, 1).', 16, 1);
END;

SELECT ThuTu, StoredProcedure, TinhHuong, MaTraVe, KetQuaKyVong
FROM (VALUES
    (1, N'dbo.usp_ThemNguoiDung', N'Chèn hợp lệ (lưu thật)',           @KQ_ND_OK,  N'0 - Thành công'),
    (2, N'dbo.usp_ThemNguoiDung', N'Thiếu tham số NOT NULL (báo lỗi)', @KQ_ND_ERR, N'1 - Báo lỗi thiếu dữ liệu'),
    (3, N'dbo.usp_ThemNhaTro',    N'Chèn hợp lệ (lưu thật)',           @KQ_NT_OK,  N'0 - Thành công'),
    (4, N'dbo.usp_ThemNhaTro',    N'Thiếu tham số NOT NULL (báo lỗi)', @KQ_NT_ERR, N'1 - Báo lỗi thiếu dữ liệu'),
    (5, N'dbo.usp_ThemDanhGia',   N'Chèn hợp lệ (lưu thật)',           @KQ_DG_OK,  N'0 - Thành công'),
    (6, N'dbo.usp_ThemDanhGia',   N'Thiếu tham số NOT NULL (báo lỗi)', @KQ_DG_ERR, N'1 - Báo lỗi thiếu dữ liệu')
) AS BangKetQua (ThuTu, StoredProcedure, TinhHuong, MaTraVe, KetQuaKyVong)
ORDER BY ThuTu;

SELECT MaND, HoTen, GioiTinh, DienThoai, SoNha, Duong, Phuong, Quan, Email
FROM dbo.NGUOIDUNG
WHERE MaND = @MaNDMoi;

SELECT MaNhaTro, MaLoai, DienTich, Gia, SoNha, Duong, Phuong, Quan, MoTa, NgayDang, MaLienHe
FROM dbo.NHATRO
WHERE MaNhaTro = @MaNhaTroMoi;

SELECT MaNhaTro, MaND, TrangThai, NoiDung
FROM dbo.DANHGIA
WHERE MaNhaTro = @MaNhaTroMoi;
GO
