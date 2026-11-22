USE QLNHATRO;
GO
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @TienToBien nvarchar(2) = NCHAR(36) + N'(';
    IF LEFT(N'$(AdminLogin)', 2) = @TienToBien OR LEFT(N'$(MemberLogin)', 2) = @TienToBien
        OR LEFT(N'$(AdminPassword)', 2) = @TienToBien OR LEFT(N'$(MemberPassword)', 2) = @TienToBien
        RAISERROR(N'Hãy bật Query → SQLCMD Mode và khai báo AdminLogin, MemberLogin, AdminPassword, MemberPassword.', 16, 1);

    IF N'$(AdminLogin)' = N'$(MemberLogin)' OR N'$(AdminPassword)' = N'$(MemberPassword)'
        RAISERROR(N'Cần hai tên đăng nhập và hai mật khẩu khác nhau.', 16, 1);

    BEGIN TRANSACTION;
    IF SUSER_ID(N'$(AdminLogin)') IS NULL
        CREATE LOGIN [$(AdminLogin)] WITH PASSWORD = '$(AdminPassword)',
            CHECK_POLICY = ON, DEFAULT_DATABASE = QLNHATRO;
    IF SUSER_ID(N'$(MemberLogin)') IS NULL
        CREATE LOGIN [$(MemberLogin)] WITH PASSWORD = '$(MemberPassword)',
            CHECK_POLICY = ON, DEFAULT_DATABASE = QLNHATRO;

    IF USER_ID(N'QLNhaTroAdmin') IS NULL
        CREATE USER [QLNhaTroAdmin] FOR LOGIN [$(AdminLogin)];
    ELSE IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'QLNhaTroAdmin'
                    AND sid = SUSER_SID(@TienToBien + N'AdminLogin)'))
    BEGIN
        ALTER USER [QLNhaTroAdmin] WITH LOGIN = [$(AdminLogin)];
        DECLARE @LoginCuAdmin nvarchar(300) = N'ALTER LOGIN ' + QUOTENAME(@TienToBien + N'AdminLogin)') + N' DISABLE;';
        EXEC sys.sp_executesql @LoginCuAdmin;
    END;
    IF USER_ID(N'QLNhaTroMember') IS NULL
        CREATE USER [QLNhaTroMember] FOR LOGIN [$(MemberLogin)];
    ELSE IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'QLNhaTroMember'
                    AND sid = SUSER_SID(@TienToBien + N'MemberLogin)'))
    BEGIN
        ALTER USER [QLNhaTroMember] WITH LOGIN = [$(MemberLogin)];
        DECLARE @LoginCuMember nvarchar(300) = N'ALTER LOGIN ' + QUOTENAME(@TienToBien + N'MemberLogin)') + N' DISABLE;';
        EXEC sys.sp_executesql @LoginCuMember;
    END;
    IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'QLNhaTroAdmin' AND sid <> SUSER_SID(N'$(AdminLogin)'))
        OR EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'QLNhaTroMember' AND sid <> SUSER_SID(N'$(MemberLogin)'))
        RAISERROR(N'User đã được ánh xạ tới login khác.', 16, 1);

    IF IS_ROLEMEMBER(N'db_owner', N'QLNhaTroAdmin') = 0
        EXEC sys.sp_addrolemember @rolename = N'db_owner', @membername = N'QLNhaTroAdmin';

    GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON OBJECT::dbo.LOAINHA TO [QLNhaTroMember];
    GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON OBJECT::dbo.NGUOIDUNG TO [QLNhaTroMember];
    GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON OBJECT::dbo.NHATRO TO [QLNhaTroMember];
    GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON OBJECT::dbo.DANHGIA TO [QLNhaTroMember];
    GRANT SELECT ON OBJECT::dbo.vw_Top10NhaTro TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.usp_ThemNguoiDung TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.usp_ThemNhaTro TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.usp_ThemDanhGia TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.usp_TimNhaTro TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.usp_XemDanhGia TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.usp_XoaNhaTroTheoDislike TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.usp_XoaNhaTroTheoNgay TO [QLNhaTroMember];
    GRANT EXECUTE ON OBJECT::dbo.fn_MaNguoiDung TO [QLNhaTroMember];
    GRANT SELECT ON OBJECT::dbo.fn_DemDanhGia TO [QLNhaTroMember];
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    DECLARE @Loi nvarchar(2048) = ERROR_MESSAGE();
    RAISERROR(N'%s', 16, 1, @Loi);
END CATCH;
GO
DECLARE @CanDoc int, @CanGhi int, @CanTim int, @CanGoiHam int, @CanDocHam int, @CanSaoLuu int;
EXECUTE AS USER = N'QLNhaTroMember';
SELECT @CanDoc = HAS_PERMS_BY_NAME(N'dbo.NHATRO', N'OBJECT', N'SELECT'),
       @CanGhi = HAS_PERMS_BY_NAME(N'dbo.NHATRO', N'OBJECT', N'INSERT'),
       @CanTim = HAS_PERMS_BY_NAME(N'dbo.usp_TimNhaTro', N'OBJECT', N'EXECUTE'),
       @CanGoiHam = HAS_PERMS_BY_NAME(N'dbo.fn_MaNguoiDung', N'OBJECT', N'EXECUTE'),
       @CanDocHam = HAS_PERMS_BY_NAME(N'dbo.fn_DemDanhGia', N'OBJECT', N'SELECT'),
       @CanSaoLuu = HAS_PERMS_BY_NAME(DB_NAME(), N'DATABASE', N'BACKUP DATABASE');
REVERT;
SELECT @CanDoc AS DocBang, @CanGhi AS GhiBang, @CanTim AS ThucThiSP, @CanGoiHam AS HamVoHuong,
       @CanDocHam AS HamBang, @CanSaoLuu AS SaoLuu;
IF ISNULL(@CanDoc, 0) <> 1 OR ISNULL(@CanGhi, 0) <> 1 OR ISNULL(@CanTim, 0) <> 1
    OR ISNULL(@CanGoiHam, 0) <> 1 OR ISNULL(@CanDocHam, 0) <> 1 OR ISNULL(@CanSaoLuu, 1) <> 0
    RAISERROR(N'Quyền của tài khoản thông thường không đúng cấu hình.', 16, 1);
GO
