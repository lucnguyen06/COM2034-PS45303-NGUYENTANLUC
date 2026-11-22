USE QLNHATRO;
GO
SET NOCOUNT ON;
SELECT N'LOAINHA' AS Bang, COUNT(*) AS SoDong FROM dbo.LOAINHA
UNION ALL SELECT N'NGUOIDUNG', COUNT(*) FROM dbo.NGUOIDUNG
UNION ALL SELECT N'NHATRO', COUNT(*) FROM dbo.NHATRO
UNION ALL SELECT N'DANHGIA', COUNT(*) FROM dbo.DANHGIA;

BEGIN TRANSACTION;
DECLARE @KQ int, @MaND int, @MaNhaTro int;
EXEC @KQ = dbo.usp_ThemNguoiDung N'Ngọc', N'F', '0900000011', N'14', N'Duy Tân', N'Dịch Vọng Hậu', N'Cầu Giấy', 'ngoc@example.test';
IF @KQ <> 0 RAISERROR(N'Thêm người dùng hợp lệ thất bại.', 16, 1);
EXEC @KQ = dbo.usp_ThemNguoiDung @Email = 'thieu@example.test';
IF @KQ <> 1 RAISERROR(N'Sai kết quả kiểm tra dữ liệu người dùng bị thiếu.', 16, 1);
SELECT @MaND = MaND FROM dbo.NGUOIDUNG WHERE Email = 'ngoc@example.test';

EXEC @KQ = dbo.usp_ThemNhaTro 1, 25.5, 2600000, N'14', N'Duy Tân', N'Dịch Vọng Hậu', N'Cầu Giấy', N'Có chỗ để xe và vệ sinh riêng.', '20261025', @MaND;
IF @KQ <> 0 RAISERROR(N'Thêm nhà trọ hợp lệ thất bại.', 16, 1);
EXEC @KQ = dbo.usp_ThemNhaTro @MaLoai = 1, @MaLienHe = @MaND;
IF @KQ <> 1 RAISERROR(N'Sai kết quả kiểm tra dữ liệu nhà trọ bị thiếu.', 16, 1);
SELECT @MaNhaTro = MaNhaTro FROM dbo.NHATRO WHERE MaLienHe = @MaND;

EXEC @KQ = dbo.usp_ThemDanhGia @MaNhaTro, 2, 'LIKE', N'Nhà sạch, dễ tìm.';
IF @KQ <> 0 RAISERROR(N'Thêm đánh giá hợp lệ thất bại.', 16, 1);
EXEC @KQ = dbo.usp_ThemDanhGia @MaNhaTro = @MaNhaTro, @MaND = 2;
IF @KQ <> 1 RAISERROR(N'Sai kết quả kiểm tra trạng thái đánh giá bị thiếu.', 16, 1);
ROLLBACK TRANSACTION;
GO
EXEC dbo.usp_TimNhaTro @Quan = N'Cầu Giấy', @DienTichTu = 25, @DienTichDen = 35,
    @NgayTu = '20261001', @NgayDen = '20261031', @GiaTu = 1500000, @GiaDen = 2000000, @MaLoai = 1;
EXEC dbo.usp_TimNhaTro @Quan = N'Thanh Xuân', @MaLoai = 2;

SELECT dbo.fn_MaNguoiDung(NULL, N'Thắng', N'M', '0900000001', N'12',
    N'Trần Duy Hưng', N'Trung Hòa', N'Cầu Giấy', 'thang@example.test') AS MaNguoiDung;
SELECT TongLike, TongDislike FROM dbo.fn_DemDanhGia(1);
SELECT TongLike, TongDislike FROM dbo.fn_DemDanhGia(11);
SELECT * FROM dbo.vw_Top10NhaTro ORDER BY TongLike DESC, MaNhaTro;
EXEC dbo.usp_XemDanhGia @MaNhaTro = 1;
GO
BEGIN TRANSACTION;
EXEC dbo.usp_XoaNhaTroTheoDislike @SoDislike = 1;
IF EXISTS (SELECT 1 FROM dbo.NHATRO WHERE MaNhaTro = 3)
    OR EXISTS (SELECT 1 FROM dbo.DANHGIA WHERE MaNhaTro = 3)
    OR NOT EXISTS (SELECT 1 FROM dbo.NHATRO WHERE MaNhaTro = 1)
    RAISERROR(N'Kiểm tra xóa theo DISLIKE thất bại.', 16, 1);
ROLLBACK TRANSACTION;
GO
BEGIN TRANSACTION;
EXEC dbo.usp_XoaNhaTroTheoNgay @NgayTu = '20261015', @NgayDen = '20261015';
IF EXISTS (SELECT 1 FROM dbo.NHATRO WHERE MaNhaTro = 8)
    OR EXISTS (SELECT 1 FROM dbo.DANHGIA WHERE MaNhaTro = 8)
    OR NOT EXISTS (SELECT 1 FROM dbo.NHATRO WHERE MaNhaTro = 9)
    RAISERROR(N'Kiểm tra xóa theo ngày thất bại.', 16, 1);
ROLLBACK TRANSACTION;
GO
IF NOT EXISTS (SELECT 1 FROM dbo.DANHGIA WHERE MaNhaTro = 3)
    OR NOT EXISTS (SELECT 1 FROM dbo.DANHGIA WHERE MaNhaTro = 8)
    RAISERROR(N'Dữ liệu mẫu chưa được khôi phục sau kiểm thử.', 16, 1);
GO
