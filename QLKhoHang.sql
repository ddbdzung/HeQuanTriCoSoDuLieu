use master
go

create database QLKhoHang
go

use QLKhoHang 
go

create table Ton
(
	MaVT nvarchar(20) not null primary key,
	TenVT nvarchar(50),
	MauSac nvarchar(20),
	SoLuong int,
	GiaBan money,
	SoLuongT int
)
create table Nhap
(
	SoHDN nvarchar(20) not null primary key,
	MaVT nvarchar(20),
	SoLuongN int,
	DonGiaN money,
	NgayN date,
	foreign key(MaVT) references Ton(MaVT)
)
create table Xuat
(
	SoHDX nvarchar(20) not null primary key,
	MaVT nvarchar(20),
	SoLuongX int,
	DonGiaX money,
	NgayX date,
	foreign key(MaVT) references Ton(MaVT)
)
insert into Ton values
('VT01', 'Vat ton A', 'Vang', 15, 1000, 10),
('VT02', 'Vat ton B', 'Cam', 15, 1000, 10),
('VT03', 'Vat ton C', 'Xanh', 15, 1000, 10),
('VT04', 'Vat ton D', 'Vang', 15, 1000, 10),
('VT05', 'Vat ton E', 'Do', 15, 1000, 10)

insert into Nhap values
('HDN01', 'VT01', 15, 500, '12/11/2000'),
('HDN02', 'VT02', 15, 500, '12/11/2001'),
('HDN03', 'VT01', 15, 500, '12/11/2002')

insert into Xuat values 
('HDX01', 'VT01', 15, 500, '12/11/2002'),
('HDX02', 'VT04', 15, 500, '12/30/2002'),
('HDX03', 'VT05', 15, 500, '06/11/2002')
select * from Nhap
select * from Xuat
select * from Ton

-- Cau 2
go
create function fn_c2(@MaVT nvarchar(20), @NgayX date)
returns @result table
(
	MaVT nvarchar(20),
	TenVT nvarchar(50),
	TienBan money
)
as
begin
	declare @TienBan money
	declare @TenVT nvarchar(50)
	set @TenVT = (select TenVT from Ton where @MaVT = MaVT)
	select @TienBan = SUM(SoLuongX * DonGiaX) from Xuat where @MaVT = MaVT and NgayX = @NgayX
	insert into @result
	select @MaVT, @TenVT, @TienBan
	return
end

-- test
select * from Xuat
select * from Ton
select * from fn_c2('VT01','2002-12-11')

-- Cau 3
go
create proc proc_c3 @SoHDX nvarchar(20), @MaVT nvarchar(20), @SoLuongX int, @DonGiaX money, @NgayX date
as
begin
	if (not exists(select * from Ton where @MaVT = Ton.MaVT))
	begin
		print N'Mã VT Không tồn tại'
		return
	end
	else
	begin
		insert into Xuat values
		(@SoHDX, @MaVT, @SoLuongX, @DonGiaX, @NgayX)
	end
	return
end

-- Test case sai - MaVT khong ton tai
select * from Xuat
select * from Ton
exec proc_c3 'HDX04', 'VT06', 15, 500, '06/11/2002'
-- Test case dung
select * from Xuat
select * from Ton
exec proc_c3 'HDX04', 'VT04', 15, 500, '06/11/2002'

-- Cau 4
go
create trigger trg_c4
on Nhap
for insert
as
begin
	declare @MaVT nvarchar(20)
	declare @SoLuongN int
	declare @SoLuongTCu int
	declare @SoLuongTMoi int
	select @MaVT = MaVT, @SoLuongN = SoLuongN from inserted
	select @SoLuongTCu = SoLuongT from Ton where @MaVT = MaVT
	if (not exists (select * from Ton where @MaVT = MaVT))
	begin
		raiserror(N'Mã VT chưa có mặt trong bảng Ton',16,1)
		rollback transaction
	end
	else
	begin
	set @SoLuongTMoi = @SoLuongN + @SoLuongTCu
		update Ton set SoLuongT = @SoLuongTMoi
		where @MaVT = MaVT
	end
end

-- Test case sai - Khong co vat tu trong bang Ton
select * from Nhap
select * from Ton
insert into Nhap values
('HDN04', 'VT07', 15, 500, '12/11/2000')

-- Test case dung
select * from Nhap
select * from Ton
insert into Nhap values
('HDN05', 'VT04', 90, 1000, '12/11/2000')