create database elMercadito

CREATE DATABASE elMercadito
ON
PRIMARY(
	NAME = elMercadito,
	FILENAME = 'C:\BDMercadito\elMercadito_PRIMARY.MDF',
	SIZE = 64,
	MAXSIZE = 5120,
	FILEGROWTH = 128),
FILEGROUP FG_HOTEL(
	NAME = DATA1,
	FILENAME = 'C:\BDMercadito\elMercadito_DATA1.NFD',
	SIZE = 64,
	MAXSIZE = 5120,
	FILEGROWTH = 128)
LOG ON(
	NAME = LOG1,
	FILENAME = 'C:\BDMercadito\elMercadito_LOG1.LFD',
	SIZE = 64,
	MAXSIZE = 1024,
	FILEGROWTH = 128)

use elMercadito

create table cliente(
cedula int primary key,
nombre varchar(50),
apellido varchar(50),
email varchar(50),
telefono varchar(50),
direccion varchar(50))

create table factura(
idFactura int identity(1000,1)  primary key,
nombreProductoF varchar(50),
costoProductoF money,
cedula int,
foreign key (cedula) references dbo.cliente (cedula))

create table producto(
codigoProducto int primary key,
nombreProducto varchar(50),
cantidadProducto int,
precioProducto money)

create table cliente_producto(
cedula int,
codigoProducto int,
constraint PK_Cedula_CodigoProducto primary key clustered
(cedula asc, codigoProducto asc),
foreign key (cedula) references dbo.cliente(cedula),
foreign key (codigoProducto) references dbo.producto(codigoProducto))

create table paquete(
codigoPaquete int identity(2000, 1) primary key,
direccionEnvio varchar(50),
tipoEnvio varchar(50),
cedula int,
foreign key (cedula) references dbo.cliente(cedula))

create table chofer(
cedulaChofer int primary key,
telefonoChofer varchar(50),
nombreChofer varchar(50),
apellidoChofer varchar(50))

create table vehiculo (
placa varchar(10) primary key,
tipoVehiculo varchar (50),
modeloVehiculo varchar(50))

create table chofer_vehiculo(
cedulaChofer int,
placa varchar(10),
constraint pk_cedulaChofer_placa primary key clustered
(cedulaChofer asc, placa asc),
foreign key (cedulaChofer) references dbo.chofer(cedulaChofer),
foreign key (placa) references dbo.vehiculo(placa))

create table paquete_vehiculo(
placa varchar(10),
codigoPaquete int,
constraint pk_placa_cedula primary key clustered
(placa asc, codigoPaquete asc),
foreign key (placa) references dbo.vehiculo(placa),
foreign key (codigoPaquete) references dbo.paquete(codigoPaquete))

--Insert en Clientes

insert into cliente values (117550809, 'Alonso', 'Araya', 'aloaraya@outlook.com', '8954-2003', 'Tejar')
insert into cliente values (307458912, 'Paula', 'Calvo', 'paucalvo@outlook.com', '8910-7689', 'Quebradilla')

--Insert en Producto

insert into producto values (100, 'Aguacate', 10, 1000)
insert into producto values (101, 'Bananos', 30, 50)

--Insert en Chofer

insert into chofer values (100056789, '2552-1775', 'Bryan', 'Ruiz')
insert into chofer values (654326359, '8365-1733', 'Froylan', 'Ledezma')

--Insert en Vehiculo

insert into vehiculo values('ABC-123', 'Camioneta', 'Citroen Van')
insert into vehiculo values('899912', 'Motocicleta', 'Serpento 2000')

--Insert en Cliente_producto

insert into dbo.cliente_producto values(117550809, 100)
insert into dbo.cliente_producto values(307458912, 101)

--Insert en chofer_vehiculo

insert into chofer_vehiculo values(100056789, 'ABC-123')
insert into chofer_vehiculo values(654326359, '899912')

select * from cliente
select * from producto
select * from cliente_producto
select * from factura
select * from paquete
select * from chofer
select * from vehiculo
select * from chofer_vehiculo
select * from paquete_vehiculo


--Factura se llena dinamicamente
-- Paquete_vehiculo se llena dinamicamente
--Paquete se llena dinamicamente


		-- Mayid

	    --Selects
		--Cliente especifico
		 Select * from cliente
		  where apellido like 'A%'
		  and   telefono='8954-2003'
		  and direccion like 'T%'

		--Chofer especifico
		 Select * from chofer
		 where cedulaChofer=100056789
		 and telefonoChofer like '%75' 
		 and apellidoChofer like 'R%'

		  --Codigo de producto asociado al cliente que lo compró
		  select b.codigoProducto,a.* 
		  from cliente a, cliente_producto b
		  where a.cedula=b.cedula

		  --Cedula ,Nombre y apellidos del chofer con el vehiculo que maneja
		  select a.cedulaChofer, CONCAT(a.nombreChofer,a.apellidoChofer) as Nombre_Completo,
		  b.placa
		  from chofer a, chofer_vehiculo b
		  where b.cedulaChofer=a.cedulaChofer

		  --Mostrar Cedula del chofer e identificacion, dependiendo del modelo de vehiculo
		  select a.cedulaChofer,CASE b.modeloVehiculo
								WHEN 'Camioneta' THEN a.nombreChofer+' '+a.apellidoChofer
								ELSE a.cedulaChofer
							  END AS 'Identificacion'
		  from chofer a, vehiculo b, chofer_vehiculo c
		  where a.cedulaChofer=c.cedulaChofer
		  and c.placa=b.placa

		--Updates
		--Aumentar el precio de los productos en un 10%
		update producto
		set precioProducto= precioProducto*1.10;

		--Disminuir el precio de los productos en un 10%
		update producto
		set precioProducto= precioProducto-((precioProducto*10)/100);

		--Modificar modelo del vehiculo
		update vehiculo
		set modeloVehiculo='BMW'
		where placa like 'AB%'

		--Delete
		delete producto where codigoProducto=100;

		delete cliente where cedula like '11%';

		delete vehiculo where placa like 'AB%';


		--Clientes

		--Insertar un cliente nuevo

		create proc creaCliente @cedulaCli int,
		 @nomCli varchar(30),
		 @apellidoCli varchar(30),
		 @email varchar(30), @telCli varchar(30), 
		 @direccionCli varchar(30), @mensaje varchar (50) output
		as
		begin
			if(select count(*) from cliente
			where @cedulaCli=cedula)=0
				insert into cliente values (@cedulaCli, @nomCli, @apellidoCli, @email, @telCli, @direccionCli)
			else
				select @mensaje='Este cliente ya existe'
		end
		go

		declare @ced int, @nom varchar(30), @apellido varchar(30),
		 @emailCli varchar(30), @tel varchar(30), @dir varchar(30), @mensj varchar(50)
		 set @ced=117550809 set @nom='Ignacio' set @apellido='Araya' set @emailCli='igaraya@outlook.com' set @tel='8910-7689' set @dir='Chepe'
		 execute creaCliente @ced, @nom,  @apellido,@emailCli, @tel, @dir, @mensj output
		 select @mensj
		 select * from cliente

		--Ver todos los clientes

		create proc verTodosClientes @mensaje varchar(50) output 
		as
		begin
			if (select count(*) from cliente)>0
				select * from cliente
			else
				select @mensaje='No hay clientes en la base de datos'
		end
		go


		declare @mens varchar(50)
		execute verTodosClientes @mens output
		select @mens


		--Ver informacion de un cliente especifico

		alter proc verCliente @cedulaCli int, @mensaje varchar(50) output
		as
		begin
			if (select count(*) from cliente
			where @cedulaCli=cedula)=1
				select * from cliente cli
				where cli.cedula=@cedulaCli
			else
				select @mensaje='No se encontro el cliente'
		end
		go

		declare @ced int, @mensj varchar(50)
		set @ced=117550800
		execute verCliente @ced, @mensj output
		select @mensj


		--Modificar un cliente en especifico

		alter proc modificaCliente @cedulaCli int, @nomCli varchar(30)=null,
		 @apellidoCli varchar(30)=null,
		 @email varchar(30)=null, @telCli varchar(30)=null, 
		 @direccionCli varchar(30)=null , @mensaje varchar (50) output
		as
		begin
			if(select count(*) from cliente
			where @cedulaCli=cedula)=1
				update cliente 
				set cliente.nombre=ISNULL(@nomCli, nombre),
				cliente.apellido=ISNULL(@apellidoCli, apellido),
				cliente.email=ISNULL(@email, email),
				cliente.telefono=ISNULL(@telCli, telefono),
				cliente.direccion=ISNULL(@direccionCli, direccion)
				where @cedulaCli=cedula
			else
				select @mensaje='No se encontro el cliente'
		end
		go

		declare @ced int, @nom varchar(30), @apellido varchar(30),
		 @emailCli varchar(30), @tel varchar(30), @dir varchar(30), @mensj varchar(50)
		 set @ced=117550800 set @nom='Alonsillo' set @apellido='Calvo' set @emailCli=null set @tel='8954-2004' set @dir='Cartago'
		 execute modificaCliente @ced, @nom,  @apellido,@emailCli, @tel, @dir, @mensj output
		 select @mensj
		 select * from cliente

		 --Borrar cliente en especifico

		alter proc borraCliente @cedulaCli int, @mensaje varchar(31) output
		as
		begin
			EXEC(' enable trigger TR_BorrarCliente on cliente_producto')
			if(select count(*) from cliente_producto 
			where @cedulaCli=cedula)=1
				delete cliente_producto
				where cedula=@cedulaCli
			else
				select @mensaje='Este cliente no esta registrado'
		end
			EXEC(' disable trigger TR_BorrarCliente on cliente_producto')
		go


		declare @ced int, @mens varchar(30)
		 set @ced=307458912
		 execute borraCliente @ced, @mens output
		 select @mens
		 select * from cliente
		 select * from cliente_producto

		 --Trigger para poder borrar de la tabla cliente

		 create trigger TR_BorrarCliente on cliente_producto
		 after delete
		 as
		 begin
			delete cliente
			where cliente.cedula=(select deleted.cedula from deleted)
		 end

 
		enable trigger TR_BorrarCliente on cliente_producto
		 go

		 disable trigger TR_BorrarCliente on cliente_producto
		 go





		--Producto

		--Insertar un producto nuevo

		create proc nuevoProd @idProd int, @nomProd varchar(50), @cantProd int, @precioProd money, @mensaje varchar(50) output
		as
		begin
			if (select count(*) from producto
			where @idProd=codigoProducto)=0
				insert into producto values (@idProd, @nomProd, @cantProd, @precioProd)
			else
				select @mensaje='Producto ya existe o tiene el mismo ID'
		end
		go

		declare @id int, @nom varchar(50), @cant int, @precio money, @mensj varchar(50)
		set @id=102 set @nom='Avena en bolsa' set @cant=15 set @precio=1000
		execute nuevoProd @id, @nom, @cant, @precio, @mensj output
		select @mensj
		select * from producto


		-- Ver todos los productos

		create proc verTodosProd @mensaje varchar(50) output
		as
		begin
			if (select count(*) from producto)>0
				select * from producto
			else
				select @mensaje='No hay productos en la base de datos'
		end
		go

		declare @mensj varchar(50)
		execute verTodosProd @mensj output
		select @mensj

		--Ver un producto en especifico

		create proc verProd @idProd int, @mensaje varchar(50) output
		as
		begin
			if (select count(*) from producto
			where @idProd=codigoProducto)=1
				select * from producto
				where @idProd=codigoProducto
			else
				select @mensaje='No se encontro el producto'
		end
		go

		declare @id int, @mensj varchar(50)
		set @id=1000
		execute verProd @id, @mensj output
		select @mensj

		--Modificar un producto en especifico
		create proc modifProd @idProd int, @nomProd varchar(50)=null, @cantProd int=null, @precioProd money=null, @mensaje varchar(50) output
		as
		begin
			if (select count(*) from producto
			where @idProd=codigoProducto)=1
				update producto
				set nombreProducto=isnull(@nomProd, nombreProducto),
				cantidadProducto=ISNULL(@cantProd, cantidadProducto),
				precioProducto=ISNULL(@precioProd, precioProducto)
				where @idProd=codigoProducto
			else
				select @mensaje='No se encontro el producto'
		end
		go

		declare @id int, @nom varchar(50), @cant int, @precio money, @mensj varchar(50)
		set @id=100 set @nom='Aguacate' set @cant=null set @precio=1000
		execute modifProd @id, @nom, @cant, @precio, @mensj output
		select @mensj
		select * from producto

		--Eliminar un producto especifico

		alter proc eliminaProd @idProd int, @mensaje varchar(50) output
		as
		begin
			EXEC('enable trigger TR_BorraProducto on cliente_producto')
			if (select count(*) from cliente_producto
			where @idProd=codigoProducto)=1
				delete cliente_producto
				where codigoProducto=@idProd
			else
				select @mensaje='No se encontro el producto'
		end
			EXEC('disable trigger TR_BorraProducto on cliente_producto')
		go

		declare @id int, @mensj varchar(50)
		set @id=101
		execute eliminaProd @id, @mensj output
		select @mensj
		select*from cliente
		select * from producto
		select * from cliente_producto


		--Trigger para borrar relacion con cliente_producto

		create trigger TR_BorraProducto on cliente_producto
		after delete
		as
		begin
			delete producto
			where codigoProducto=(select deleted.codigoProducto from deleted)
		end
		go

		enable trigger TR_BorraProducto on cliente_producto
		go


		--Chofer

		--Crear un nuevo chofer

			create proc nuevoChofer @cedula int, @tel varchar(30), @nom varchar(30),
		 @apellido varchar(30), @mensaje varchar (50) output
		as
		begin
			if(select count(*) from chofer
			where @cedula=cedulaChofer)=0
				insert into chofer values (@cedula, @tel, @nom, @apellido)
			else
				select @mensaje='Chofer con mismo id o ya existe'
		end
		go

		declare @ced int, @tel varchar(30), @nom varchar(30),
		 @apellido varchar(30), @mensj varchar(50)
		 set @ced=12345678 set @tel='8954-3456' set @nom='Juan' set @apellido='Mata'
		 execute nuevoChofer @ced, @tel, @nom, @apellido, @mensj output
		 select @mensj
		 select * from chofer

		--Ver todos los choferes

		create proc verTodosChoferes @mensaje varchar(50) output 
		as
		begin
			if (select count(*) from chofer)>0
				select * from chofer
			else
				select @mensaje='No hay choferes en la base de datos'
		end
		go


		declare @mens varchar(50)
		execute verTodosChoferes @mens output
		select @mens


		--Ver informacion de un chofer especifico

		create proc verChofer @cedula int, @mensaje varchar(50) output
		as
		begin
			if (select count(*) from chofer
				where @cedula=cedulaChofer)=1
				select * from chofer chof
				where chof.cedulaChofer=@cedula
			else
				select @mensaje='No se encontro el chofer'
		end
		go

		declare @ced int, @mensj varchar(50)
		set @ced=100056789
		execute verChofer @ced, @mensj output
		select @mensj


		--Modificar un chofer en especifico

		create proc modificaChofer @cedula int, @tel varchar(30)=null, @nom varchar(30)=null,
		 @apellido varchar(30)=null, @mensaje varchar (50) output
		as
		begin
			if(select count(*) from chofer
			where @cedula=cedulaChofer)=1
				update chofer
				set telefonoChofer=ISNULL(@tel, telefonoChofer),
				nombreChofer=ISNULL(@nom, nombreChofer),
				apellidoChofer=ISNULL(@apellido, apellidoChofer)
				where @cedula=cedulaChofer
			else
				select @mensaje='No se encontro el chofer'
		end
		go

		declare @ced int, @tel varchar(30), @nom varchar(30),
		 @apellido varchar(30), @mensj varchar(50)
		 set @ced=1000567890 set @tel='8954-2001' set @nom='Wayne' set @apellido='Rooney'
		 execute modificaChofer @ced, @tel, @nom, @apellido, @mensj output
		 select @mensj
		 select * from chofer

		 --Borrar un chofer en especifico

			alter proc borraChofer @cedula int, @mensaje varchar(31) output
			as
			begin
			exec('enable trigger TR_BorraChofer on chofer_vehiculo')
				if(select count(*) from chofer_vehiculo
				where @cedula=cedulaChofer)=1
					delete chofer_vehiculo
					where cedulaChofer=@cedula
				else
					 select @mensaje='Este chofer no esta registrado'
			end
			exec(' disable trigger TR_BorraChofer on chofer_vehiculo')
			go

			declare @ced int, @mens varchar(30)
			 set @ced=100056789
			 execute borraChofer @ced, @mens output
			 select @mens
			 select * from chofer
			 select * from chofer_vehiculo
			 select * from vehiculo


		 --Trigger para borrar relacion de Chofer con conduce

		 create trigger TR_BorraChofer on chofer_vehiculo
		 after delete
		 as
		 begin
			 delete chofer
			 where cedulaChofer=(select deleted.cedulaChofer from deleted)
		 end
		 go

		 enable trigger TR_BorraChofer on chofer_vehiculo


		 --Vehiculos

		 --Crear un nuevo vehiculo

		 create proc nuevoVehiculo @placa varchar(50), @tipo varchar(30),
		 @modelo varchar(30), @mensaje varchar (50) output
		as
		begin
			if(select count(*) from vehiculo
			where @placa=placa)=0
				insert into vehiculo values (@placa, @tipo, @modelo)
			else
				select @mensaje='Id de vehiculo duplicado o ya existe'
		end
		go

		declare @pVehi varchar(50), @tVehi varchar(30),
		 @modVehi varchar(30), @mensj varchar(50)
		 set @pVehi='AAC-269' set @tVehi='Automovil' set @modVehi='BMW 318i' 
		 execute nuevoVehiculo @pVehi, @tVehi, @modVehi, @mensj output
		 select @mensj
		 select * from vehiculo

		 --Ver todos los vehiculos

		 create proc verTodosVehiculos @mensaje varchar(50) output 
		as
		begin
			if (select count(*) from vehiculo)>0
				select * from vehiculo
			else
				select @mensaje='No hay vehiculos en la base de datos'
		end
		go


		declare @mens varchar(50)
		execute verTodosVehiculos @mens output
		select @mens


		--Ver informacion de un vehiculo especifico

		create proc verVehiculo @placa varchar(50), @mensaje varchar(50) output
		as
		begin
			if (select count(*) from vehiculo
			where @placa=placa)=1
				select * from vehiculo vehi
				where vehi.placa=@placa
			else
				select @mensaje='No se encontro el vehiculo'
		end
		go

		declare @plac varchar(50), @mensj varchar(50)
		set @plac='ABC-123'
		execute verVehiculo @plac, @mensj output
		select @mensj


		--Modificar un vehiculo en especifico

		create proc modificaVehiculo @placa varchar(50)=null, @tipo varchar(30)=null,
		 @modelo varchar(30)=null, @mensaje varchar (50) output
		as
		begin
			if(select count(*) from vehiculo
			where @placa=placa)=1
				update vehiculo
				set tipoVehiculo=ISNULL(@tipo, tipoVehiculo),
				modeloVehiculo=ISNULL(@modelo, modeloVehiculo)
				where @placa=placa
			else
				select @mensaje='No se encontro el Vehiculo'
		end
		go

		declare @pVehi varchar(50), @tVehi varchar(30),
		 @modVehi varchar(30), @mensj varchar(50)
		 set @pVehi='ABC-123' set @tVehi='Automovil 4x4' set @modVehi='Toyota Land Cruiser' 
		 execute modificaVehiculo @pVehi, @tVehi, @modVehi, @mensj output
		 select @mensj
		 select * from vehiculo

		 --Borrar un vehiculo en especifico

		create proc borraVehiculo @placa varchar(50), @mensaje varchar(31) output
		as
		begin
		EXEC('enable trigger TR_BorrarVehiculo on chofer_vehiculo')
			if(select count(*) from chofer_vehiculo
			where @placa=placa)=1
				delete chofer_vehiculo
				where @placa=placa
			else
				select @mensaje='Este Vehiculo no esta registrado'
		end
			EXEC('disable trigger TR_BorrarVehiculo on chofer_vehiculo')
		go

		declare @plac varchar(50), @mens varchar(30)
		 set @plac='ABC-123'
		 execute borraVehiculo @plac, @mens output
		 select @mens
		 select * from vehiculo
		 select * from chofer_vehiculo
		 select * from chofer


		 --Trigger para borrar relacion de Chofer con conduce

		 create trigger TR_BorrarVehiculo on chofer_vehiculo
		 after delete
		 as
		 begin
			 delete vehiculo
			 where placa=(select deleted.placa from deleted)
		 end
		 go

		 enable trigger TR_BorrarVehiculo on chofer_vehiculo

		 --Chofer_Vehiculo

		 --Asignar vehiculo a chofer

		 create proc asignaVehiculo @cedula int, @placa varchar(50), @mensaje varchar(50) output
		 as
		 begin
			 if(select count(*) from chofer 
			 where cedulaChofer=@cedula)=1 and (select count(*) from vehiculo where @placa=placa)=1
				insert into chofer_vehiculo values(@cedula, @placa)
			 else
				 select @mensaje='No se encuentra chofer o vehiculo'
			 end
		 go

		 declare @ced int, @plac varchar(50), @mensj varchar(50)
		 set @ced=654326359 set @plac='AAC-269'
		 exec asignaVehiculo @ced, @plac, @mensj output
		 select @mensj
		 select * from chofer
		 select * from vehiculo
		 select * from chofer_vehiculo


		--Compra_Producto

		--Realizar compra de un producto

		alter proc compra @cedCli int, @idProd int, @mensaje varchar(50) output
		as
		begin
			if(select count(*) from cliente where @cedCli=cedula)=1 and (select count(*) from producto where @idProd=codigoProducto)=1
				begin
					insert into cliente_producto values (@cedCli, @idProd)
				end
		    else
				begin
					select @mensaje='No se encontro cliente o producto'
				end
		end
		go


		declare @ced int, @id int, @mensj varchar(50)
		set @ced=117550809
		set @id=102
		execute compra @ced, @id, @mensj output
		select @mensj
		select * from cliente_producto
		
		--Facturas

		--Generar tabla Factura con todos los datos hasta el momento

		create proc verFactura
		as
		declare @nombreFac varchar(50),
		@costoFac money,
		@cedulaFac int,
		@codigoNuevo int

		declare cursor_factura cursor for

				select prod.nombreProducto, prod.precioProducto, cli.cedula
				from cliente_producto cliProd, producto prod, cliente cli
				where cli.cedula=cliProd.cedula
				and prod.codigoProducto=cliProd.codigoProducto

		open cursor_factura

		fetch cursor_factura into @nombreFac, @costoFac, @cedulaFac

			while @@FETCH_STATUS=0
				begin
					insert into factura (factura.nombreProductoF, factura.costoProductoF, factura.cedula) values ( @nombreFac, @costoFac, @cedulaFac)
					fetch cursor_factura into @nombreFac, @costoFac, @cedulaFac
				end

			close cursor_factura
			deallocate cursor_factura
			go

			exec verFactura
			select * from factura

			--Ver factura de un cliente

			create proc verFacturaCliente @cedula int, @mensaje varchar(50) output
			as
			begin
				if(select count(*) from factura
				where cedula=@cedula)>0
					select * from factura
					where cedula=@cedula
				else
					select @mensaje='No se encontraron facturas a este cliente'
			end
			go

			declare @ced int, @mens varchar(50)
			set @ced=117550809
			exec verFacturaCliente @ced, @mens output
			select @mens

			--Borrar Factura de un cliente

			create proc borrarFacturaCliente @cedula int, @mensaje varchar(50) output
			as
			begin
				if(select count(*) from factura
				where cedula=@cedula)>0
					delete factura
					where cedula=@cedula
				else
					select @mensaje='No se encontraron facturas a este cliente'
			end
			go

			declare @ced int, @mens varchar(50)
			set @ced=307458912
			exec borrarFacturaCliente @ced, @mens output
			select @mens
			select * from factura

			--Paquete

			select * from paquete

			--Generar paquete

			create proc crearPaquete @cedula int, @tipoEnv varchar(50), @mensaje varchar(50) output
			as
			declare @direccion varchar(50)

			begin
				select @direccion=(select direccion from cliente where cedula=@cedula)
				if(select count(*) from factura
				where cedula=@cedula)>0
				    insert into paquete (direccionEnvio, tipoEnvio, cedula) values (@direccion, @tipoEnv, @cedula)
				else
					select @mensaje='No se ha podido crear el paquete'
			end
			go

			declare @ced int, @tipoE varchar(50), @mens varchar(50)
			set @ced=117550809 set @tipoE='Rapido'
			exec crearPaquete @ced, @tipoE, @mens output
			select* from paquete

			--Ver Paquete en especifico

			create proc verPaquete @cedula int, @mensaje varchar(50) output
			as
			begin
				if(select count(*) from factura
				where cedula=@cedula)>0
				select * from paquete
				where cedula=@cedula
				else    
				select @mensaje='No se ha podido crear el paquete'
			end
			go

			declare @ced int, @mens varchar(50)
			set @ced=117550809 
			exec verPaquete @ced, @mens output
			select* from paquete

			--Eliminar paquete

			alter proc borrarPaquete @cedula int, @mensaje varchar(50) output
			as
			begin
				if(select count(*) from factura
				where cedula=@cedula)>0
				delete paquete
				where cedula=@cedula
				else    
				select @mensaje='No se ha podido encontrar el paquete'
			end
			go

			declare @ced int, @mens varchar(50)
			set @ced=117550809 
			exec borrarPaquete @ced, @mens output
			select* from paquete


	
		--Borrar en cascada las Tablas
		drop table cliente_producto
		drop table paquete_vehiculo;
		drop table chofer_vehiculo;
		drop table producto;
		drop table factura;
		drop table paquete;
		drop table cliente;
		drop table chofer;
		drop table vehiculo;


