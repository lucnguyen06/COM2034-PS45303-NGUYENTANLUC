USE QLNHATRO;
GO
DECLARE @LoginHienTai sysname = ORIGINAL_LOGIN();
DECLARE @UserHienTai sysname = USER_NAME();
DECLARE @ThuMucSaoLuu nvarchar(4000);
DECLARE @BakPath nvarchar(4000) = NULL;

IF @UserHienTai <> N'QLNhaTroAdmin' OR ISNULL(IS_ROLEMEMBER(N'db_owner'), 0) <> 1
    OR NOT EXISTS (
        SELECT 1 FROM sys.database_principals
        WHERE principal_id = USER_ID() AND sid = SUSER_SID(@LoginHienTai)
    )
BEGIN
    RAISERROR(N'Login hiện tại: %s, user CSDL: %s. Hãy mở kết nối mới bằng login quản trị đã tạo trong 04_PhanQuyen.sql.',
        16, 1, @LoginHienTai, @UserHienTai);
    RETURN;
END;

IF @BakPath IS NULL
BEGIN
    SET @ThuMucSaoLuu = CONVERT(nvarchar(4000), SERVERPROPERTY('InstanceDefaultBackupPath'));
    IF NULLIF(@ThuMucSaoLuu, N'') IS NULL
    BEGIN
        RAISERROR(N'Không tìm được thư mục sao lưu mặc định. Hãy nhập đường dẫn đầy đủ tới tệp .bak vào @BakPath.', 16, 1);
        RETURN;
    END;
    SET @BakPath = @ThuMucSaoLuu
        + CASE WHEN RIGHT(@ThuMucSaoLuu, 1) IN (N'\', N'/') THEN N'' ELSE N'\' END
        + N'QLNHATRO_' + CONVERT(nvarchar(36), NEWID()) + N'.bak';
END;

SELECT @LoginHienTai AS LoginHienTai, @UserHienTai AS UserCSDL, DB_NAME() AS CoSoDuLieu, @BakPath AS TepSaoLuu;
BACKUP DATABASE QLNHATRO TO DISK = @BakPath WITH COPY_ONLY, CHECKSUM, STATS = 10;
GO