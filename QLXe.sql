GO
USE MASTER
GO

CREATE DATABASE QLXE

GO
USE QLXE
GO

CREATE TABLE Xe
(
	MaXe NVARCHAR(10) NOT NULL PRIMARY KEY,
	TenXe NVARCHAR(50) NOT NULL,
	SoLuong INT
)
GO

CREATE TABLE KhachHang
(
	MaKH NVARCHAR(10) NOT NULL PRIMARY KEY,
	TenKH NVARCHAR(50) NOT NULL,
	DiaChi NVARCHAR(50) NOT NULL,
	SoDT VARCHAR(12) NOT NULL,
	Email VARCHAR(50) NOT NULL,
)
GO

CREATE TABLE ThueXe
(
	SoHD NVARCHAR(10) NOT NULL PRIMARY KEY,
	MaKH NVARCHAR(10) NOT NULL,
	MaXe NVARCHAR(10) NOT NULL,
	SoNgayThue INT,
	SoLuongThue INT,
	FOREIGN KEY(MaKH) REFERENCES KhachHang(MaKH),
	FOREIGN KEY(MaXe) REFERENCES Xe(MaXe)
)
GO

INSERT INTO Xe VALUES
('XE01', N'HONDA', 10),
('XE02', N'TOYOTA', 15),
('XE03', N'SH', 20)

INSERT INTO KhachHang VALUES
('KH01', N'Nguyễn Văn A', N'Hà Nội', '0987654321', 'nva@gmail.com'),
('KH02', N'Nguyễn Văn B', N'HCM', '0123456789', 'nvb@gmail.com'),
('KH03', N'Nguyễn Văn C', N'Nam Định', '0987123654', 'nvc@gmail.com')

INSERT INTO ThueXe VALUES
('HD01', 'KH01', 'XE01', 15, 3),
('HD02', 'KH01', 'XE02', 15, 3),
('HD03', 'KH01', 'XE03', 15, 3),
('HD04', 'KH02', 'XE02', 15, 3),
('HD05', 'KH03', 'XE01', 15, 3)

SELECT * FROM Xe
SELECT * FROM KhachHang
SELECT * FROM ThueXe
GO

CREATE FUNCTION FN_Cau2 (@que NVARCHAR(50))
RETURNS INT
AS
	BEGIN
		DECLARE @tong INT
		SELECT @tong = (SELECT SUM(SoLuongThue)
		FROM ThueXe INNER JOIN KhachHang ON KhachHang.MaKH = ThueXe.MaKH
		WHERE DiaChi = @que)
		RETURN @TONG
	END
GO

SELECT dbo.FN_Cau2(N'Hà Nội') AS 'Tong'

-- Cau 3
GO
ALTER PROC Proc_Cau3 @SoHD NVARCHAR(10), @SoNgayThue int, @SoLuongThue int, @MaKH NVARCHAR(10), @MaXe NVARCHAR(10),
@kq INT OUTPUT
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM KhachHang WHERE @MaKH = MaKH)
	BEGIN
		PRINT N'Mã KH không tồn tại'
		SET @kq = 1
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM Xe WHERE @MaXe = MaXe)
	BEGIN
		PRINT N'Mã xe không tồn tại'
		SET @kq = 2
		RETURN
	END
	
	SET @kq = 0
	INSERT INTO ThueXe VALUES 
	(@SoHD, @MaKH, @MaXe, @SoNgayThue, @SoLuongThue)
	RETURN
END
GO

DECLARE @kq INT
EXEC Proc_Cau3 'HD06', 10, 2, 'KH02', 'XE03', @kq OUTPUT

-- Cau 4
go
create trigger trg_c4
on ThueXe
for insert
as
begin
	declare @MaXe nvarchar(10)
	declare @SoLuongThue int
	declare @SoLuongConLai int
	declare @SoLuong int
	set @MaXe = (select MaXe from inserted)
	set @SoLuongThue = (select SoLuongThue from inserted)
	set @SoLuong = (select SoLuong from inserted inner join Xe on Xe.MaXe = Xe.MaXe where @MaXe = Xe.MaXe)
	if (@SoLuongThue > @SoLuong)
	begin
		raiserror(N'Số lượng xe trong kho không đủ để thuê',16,1)
		rollback transaction
	end
	else
	begin
		set @SoLuongConLai = @SoLuong - @SoLuongThue
		update Xe set SoLuong = @SoLuongConLai
		where MaXe = @MaXe
	end
end
go

-- Khong hop le
select * from ThueXe
select * from Xe
insert into ThueXe values
('HD08', 'KH01', 'XE01', 16, 50)

-- Hop le
select * from ThueXe
select * from Xe
insert into ThueXe values
('HD09', 'KH01', 'XE01', 16, 5)
