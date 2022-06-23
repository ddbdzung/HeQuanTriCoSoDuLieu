use master
go

create database QLSinhVien_KhanhTho
go

use QLSinhVien_KhanhTho
go

create table Khoa
(
	MaKhoa nvarchar(20) not null primary key,
	TenKhoa nvarchar(20),
	DiaChi nvarchar(50),
	SoDT nvarchar(12),
	Email nvarchar(50)
)
create table Lop
(
	MaLop nvarchar(20) not null primary key,
	TenLop nvarchar(20),
	SiSo int,
	MaKhoa nvarchar(20) not null,
	Phong nvarchar(20),
	foreign key (MaKhoa) references Khoa(MaKhoa)
)
create table SinhVien
(
	MaSV nvarchar(20) not null primary key,
	HoTen nvarchar(50),
	NgaySinh date,
	GioiTinh nvarchar(10),
	MaLop nvarchar(20) not null,
	foreign key (MaLop) references Lop(MaLop)
)

insert into Khoa values
('KHOA01', 'KHOA A', 'Dia chi A', '0987654321', 'KhoaA@gmail.com'),
('KHOA02', 'KHOA B', 'Dia chi B', '0987654322', 'KhoaB@gmail.com'),
('KHOA03', 'KHOA C', 'Dia chi C', '0987654323', 'KhoaC@gmail.com')
insert into Lop values
('LOP01', 'CNTT1', 75, 'KHOA01', 'Phong A'),
('LOP02', 'CNTT2', 75, 'KHOA02', 'Phong A'),
('LOP04', 'CNTT3', 55, 'KHOA01', 'Phong B')
insert into SinhVien values
('SV01', 'Nguyen Van A', '03/10/2002', 'Nam', 'LOP01'),
('SV02', 'Nguyen Van B', '03/10/2002', 'Nam', 'LOP02'),
('SV03', 'Nguyen Van C', '03/10/2002', 'Nam', 'LOP03'),
('SV04', 'Nguyen Thi D', '03/10/2002', 'Nu', 'LOP03'),
('SV05', 'Nguyen Thi E', '03/10/2002', 'Nu', 'LOP01')

select * from Khoa
select * from Lop
select * from SinhVien

-- Cau 2
go
create function fnCau2(@TenKhoa nvarchar(20), @TenLop nvarchar(20))
returns @result table
(
	MaSV nvarchar(20),
	HoTen nvarchar(50),
	Tuoi int
)
as
begin
	declare @Tuoi int
	declare @NgaySinh date
	insert into @result
	select MaSV, HoTen, (year(GETDATE())-year(NgaySinh)) as 'Tuoi' from SinhVien 
	inner join Lop on Lop.MaLop = SinhVien.MaLop
	inner join Khoa on Khoa.MaKhoa = Lop.MaKhoa
	where @TenKhoa = Khoa.TenKhoa and @TenLop = Lop.TenLop
	return
end

select * from dbo.fnCau2('KHOA A', 'CNTT1')

-- Cau 3
go
alter proc procCau3 @TuTuoi int, @DenTuoi int
as
begin
	declare @ds table
	(
		MaSV nvarchar(20),
		HoTen nvarchar(50),
		NgaySinh date,
		TenLop nvarchar(20),
		TenKhoa nvarchar(20),
		Tuoi int
	)
	insert into @ds
	select MaSV, HoTen, NgaySinh, TenLop, TenKhoa, (year(GETDATE())-year(NgaySinh)) as 'Tuoi'
	from SinhVien 
	inner join Lop on Lop.MaLop = SinhVien.MaLop
	inner join Khoa on Khoa.MaKhoa = Lop.MaKhoa
	where (year(GETDATE())-year(NgaySinh)) >= @TuTuoi
	and (year(GETDATE())-year(NgaySinh)) < @DenTuoi
	select * from @ds
end

-- Thuc thi
exec procCau3 21, 22

-- Cau 4
go
create trigger trgCau4
on SinhVien
for insert
as
begin
	declare @MaSV nvarchar(20)
	declare @MaLop nvarchar(20)
	declare @SiSo int
	select @MaSV = MaSV, @MaLop = MaLop from inserted
	select @SiSo = SiSo from SinhVien
	inner join Lop on SinhVien.MaLop = Lop.MaLop
	where @MaSV = MaSV
	if (@SiSo > 60)
	begin
		raiserror(N'Khong cho si so qua 60',16,1)
		rollback transaction
	end
	else
	begin
		update Lop set SiSo = @SiSo + 1
		where @MaLop = MaLop
	end
end

select * from SinhVien
select * from Lop
insert into SinhVien values
-- Dung
('SV07', 'Nguyen Thi E', '03/10/2002', 'Nu', 'LOP04')
-- Sai
('SV07', 'Nguyen Thi E', '03/10/2002', 'Nu', 'LOP03')