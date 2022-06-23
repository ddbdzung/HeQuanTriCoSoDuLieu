USE master
GO

CREATE DATABASE QLTruongHoc
GO

USE QLTruongHoc
GO

CREATE TABLE GiaoVien
(
	MaGV nvarchar(10) NOT NULL PRIMARY KEY,
	TenGV nvarchar(50) NOT NULL
)

CREATE TABLE Lop
(
	MaLop nvarchar(10) NOT NULL PRIMARY KEY,
	TenLop nvarchar(20) NOT NULL,
	Phong nvarchar(10),
	SiSo int,
	MaGV nvarchar(10) NOT NULL,
	FOREIGN KEY(MaGV) REFERENCES GiaoVien(MaGV)
)

CREATE TABLE SinhVien
(
	MaSV nvarchar(10) NOT NULL PRIMARY KEY,
	TenSV nvarchar(50) NOT NULL,
	GioiTinh nvarchar(10),
	QueQuan nvarchar(50),
	MaLop nvarchar(10) NOT NULL,
	FOREIGN KEY(MaLop) REFERENCES Lop(MaLop)
)

INSERT INTO GiaoVien VALUES
('GV01', N'Nguyen Thi A'),
('GV02', N'Nguyen Thi B'),
('GV03', N'Nguyen Thi C')
INSERT INTO Lop VALUES
('LOP01', N'CNTT01', N'A3', 75, 'GV01'),
('LOP02', N'CNTT02', N'A4', 75,	'GV02'),
('LOP03', N'CNTT03', N'A5', 75,	'GV01')
INSERT INTO SinhVien VALUES
('SV01', N'Nguyen Van A', N'Nam', N'Ha Noi', 'LOP01'),
('SV02', N'Nguyen Van B', N'Nu', N'HCM', 'LOP02'),
('SV03', N'Nguyen Van C', N'Nam', N'Ha Noi', 'LOP01'),
('SV04', N'Nguyen Van D', N'Nu', N'Ha Noi', 'LOP03'),
('SV05', N'Nguyen Van E', N'Nam', N'Ha Noi', 'LOP02')
GO
SELECT * FROM GiaoVien
SELECT * FROM Lop
SELECT * FROM SinhVien
--drop table Lop
--drop table SinhVien
GO
CREATE FUNCTION FnCau2(@TenLop nvarchar(20), @TenGV nvarchar(50))
RETURNS @result TABLE 
(
	MaSV nvarchar(10),
	TenSV nvarchar(50),
	GioiTinh nvarchar(10),
	QueQuan nvarchar(50),
	MaLop nvarchar(10)
)
AS
BEGIN
	-- Cach 1
	DECLARE @MaGV nvarchar(10)
	DECLARE @MaLop nvarchar(10) 
	SET @MaGV = (SELECT MaGV FROM GiaoVien WHERE @TenGV = TenGV)
	SET @MaLop = (SELECT MaLop FROM Lop WHERE @TenLop = TenLop AND @MaGV = MaGV)
	INSERT INTO @result 
	SELECT * FROM SinhVien WHERE @MaLop = MaLop;
	RETURN 

	-- Cach 2
	/*
	INSERT INTO @result
	SELECT MaSV,TenSV,GioiTinh,QueQuan,SinhVien.MaLop FROM SinhVien 
	INNER JOIN Lop ON Lop.MaLop = SinhVien.MaLop
	INNER JOIN GiaoVien ON GiaoVien.MaGV = Lop.MaGV
	WHERE TenLop = @TenLop AND TenGV = @TenGV
	RETURN
	*/
END
GO

SELECT * FROM FnCau2(N'CNTT02',N'Nguyen Thi B')

-- Cau 3
go
ALTER proc Proc_C3 @MaSV nvarchar(10), @TenSV nvarchar(50), @GioiTinh nvarchar(10), @QueQuan nvarchar(50), @TenLop nvarchar(20)
AS
BEGIN
	if not exists (select * from Lop where Lop.TenLop = @TenLop)
	begin
		print N'Không tồn tại tên lớp'
		return
	end
	declare @MaLop nvarchar(10)
	set @MaLop = (select MaLop from Lop where TenLop = @TenLop)
	insert into SinhVien values
	(@MaSV , @TenSV , @GioiTinh, @QueQuan , @MaLop )
	return
END
go

exec Proc_C3 'SV02',N'Nguyen Van Z',N'Nam',N'Ha Noi',N'CNTT02'

-- Cau 4
go
alter trigger trgc04
on SinhVien
for update
as
begin
	declare @MaLopCu nvarchar(10)
	declare @MaLopMoi nvarchar(10)
	declare @SiSoLopCu int
	declare @SiSoLopMoi int
	set @MaLopCu = (select MaLop from deleted)
	set @MaLopMoi = (select MaLop from inserted)
	if (@MaLopCu = @MaLopMoi)
	begin
		raiserror(N'Không thể update dữ liệu trùng lặp MaLop',16,1)
		rollback transaction
	end
	else
	begin
	set @SiSoLopCu = (select SiSo from Lop where @MaLopCu = Lop.MaLop)
	set @SiSoLopMoi = (select SiSo from Lop where @MaLopMoi = Lop.MaLop)
	update Lop set SiSo = @SiSoLopCu - 1
	where Lop.MaLop = @MaLopCu
	update Lop set SiSo = @SiSoLopMoi + 1
	where Lop.MaLop = @MaLopMoi
	end
end
go

SELECT * FROM Lop
SELECT * FROM SinhVien
-- Test case sai - Du lieu khong ton tai
update SinhVien set MaLop = N'LOP09'
where MaSV = N'SV01'

-- Test case sai - Du lieu trung lap
update SinhVien set MaLop = N'LOP03'
where MaSV = N'SV01'

-- Test case dung 
update SinhVien set MaLop = N'LOP01'
where MaSV = N'SV01'

