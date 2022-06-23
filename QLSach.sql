USE master
GO

CREATE DATABASE QLSach_CuoiKi
GO
USE QLSach_CuoiKi
GO

CREATE TABLE TacGia
(
	MaTG char(20) NOT NULL PRIMARY KEY,
	TenTG nvarchar(50),
	SoLuongCo int
)
CREATE TABLE NhaXB
(
	MaNXB char(20) NOT NULL PRIMARY KEY,
	TenNXB nvarchar(100),
	SoLuongCo int
)
CREATE TABLE Sach
(
	MaSach char(20) NOT NULL PRIMARY KEY,
	TenSach nvarchar(50),
	MaNXB char(20) NOT NULL,
	MaTG char(20) NOT NULL,
	NamXB int,
	SoLuong int,
	DonGia money,
	FOREIGN KEY(MaNXB) REFERENCES NhaXB(MaNXB),
	FOREIGN KEY(MaTG) REFERENCES TacGia(MaTG)
)

INSERT INTO TacGia VALUES
('TG01', N'Nguyễn Văn A', 10),
('TG02', N'Nguyễn Văn B', 10),
('TG03', N'Nguyễn Văn C', 10)
INSERT INTO NhaXB VALUES
('NXB01', N'Nha Xuat Ban A', 1000),
('NXB02', N'Nha Xuat Ban B', 1000),
('NXB03', N'Nha Xuat Ban C', 1000)
INSERT INTO Sach VALUES
('S01', N'Ten sach A', 'NXB01', 'TG01', 2000, 500, 10000),
('S02', N'Ten sach B', 'NXB01', 'TG02', 2000, 500, 10000),
('S03', N'Ten sach C', 'NXB01', 'TG03', 2001, 500, 20000),
('S04', N'Ten sach D', 'NXB03', 'TG01', 2002, 500, 20000),
('S05', N'Ten sach E', 'NXB02', 'TG02', 2002, 500, 10000)
SELECT * FROM TacGia
SELECT * FROM Sach
SELECT * FROM NhaXB
GO
CREATE FUNCTION FnCau3(@TenTG nvarchar(50))
RETURNS money
AS
BEGIN
	DECLARE @TienBan money
	SET @TienBan = (SELECT SUM(SoLuong * DonGia)
	FROM TacGia INNER JOIN Sach ON TacGia.MaTG = Sach.MaTG
	WHERE @TenTG = TacGia.TenTG)
	RETURN @TienBan
END
GO

SELECT dbo.FnCau3(N'Nguyễn Văn A')

-- Cau 2
go
create proc proc_c2 @MaSach char(20), @TenSach nvarchar(50), @TenNXB nvarchar(100), @MaTG char(20), @NamXB int,@SoLuong int, @DonGia money
as
begin
	if not exists (select TenNXB from NhaXB where @TenNXB = NhaXB.TenNXB)
	begin
		print N'Nhà xuất bản không tồn tại.'
	end
	else
	begin
		declare @MaNXB char(20)
		set @MaNXB = (select MaNXB from NhaXB where @TenNXB = NhaXB.TenNXB)
		insert into Sach values
		(@MaSach, @TenSach, @MaNXB, @MaTG, @NamXB, @SoLuong, @DonGia)
	end
	return
end
go
select * from Sach
select * from NhaXB
-- test case sai - NXB khong ton tai
exec proc_c2 'S06', 'Ten sach F', 'Nha Xuat Ban D', 'TG02', 2000, 1000, 20000
go

-- test case dung 
exec proc_c2 'S06', 'Ten sach F', N'Nha Xuat Ban B', 'TG02', 2000, 1000, 20000
go

-- Cau 4
alter trigger trg_c4 
on Sach
for insert
as
begin
	declare @MaNXB char(20)
	set @MaNXB = (select MaNXB from inserted)
	if (not exists (select * from NhaXB where NhaXB.MaNXB = @MaNXB))
	begin
		raiserror(N'Mã nxb chưa có mặt trong bảng nhaxb',16,1)
		rollback transaction
	end
	else
	begin
		declare @SoLuong int
		declare @SoLuongCoMoi int
		declare @SoLuongCo int
		set @SoLuong = (select SoLuong from inserted)
		set @SoLuongCo = (select SoLuongCo from NhaXB where MaNXB = @MaNXB)
		set @SoLuongCoMoi = @SoLuong + @SoLuongCo
		update NhaXB set SoLuongCo = @SoLuongCoMoi
		where MaNXB = @MaNXB
	end
end
go


-- test case sai: MaNXB k ton tai
insert into Sach values
('S07', N'Ten sach ZZ', 'NXB04', 'TG02', 2002, 500, 10000)
select * from Sach
select * from NhaXB
-- test case dung
insert into Sach values
('S08', N'Ten sach ZZ', 'NXB03', 'TG02', 2002, 500, 10000)
select * from Sach
select * from NhaXB