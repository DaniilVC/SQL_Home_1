-- Килимджьян Даниил Владимирович
-- Вариант 19
/* Описание таксопарка. 
Включает в себя: автомобили, водителей, тарифы, заказы, информацию об оплате. 

Описания автомобилей состоят из: марки, класса (бизнес, эконом), 
госномера автомобиля, цвета, года выпуска. 

Водитель описывается: 
фамилией, именем, отчеством, датой рождения, ИНН, серией и номером паспорта.

Описания тарифов состоят из: 
названия, указания времени суток (день/ночь), 
указания дальности поездки с точки зрения удалённости от центра Москвы
(в пределах МКАД, за МКАД, Подмосковье), цена за километр пути.

Заказы описываются: датой, временем, адресом подачи такси,
предположительным адресом следования такси, количеством пассажиров,
ориентировочной длиной маршрута. 

Информация об оплате состоит из указания заказа,
указания тарифа, километража, стоимости.

В одном заказе тарифы могут комбинироваться 
(в этом случае, для каждого тарифа собственная информация об оплате).
Каждый водитель на все заказы ездит на одной и той же машине, 
но у разных водителей машины могут быть разными.
*/

CREATE SCHEMA taxi_company;

-- водитель
CREATE TABLE taxi_company.drivers (
	id SERIAL PRIMARY KEY,
	birthday date NOT NULL,
	first_name varchar(64) NOT NULL,
	last_name varchar(64) NOT NULL,
	second_name varchar(64),
	inn char(12) NOT NULL UNIQUE,
	serial_passport char(4) NOT NULL,
	number_passport char(6) NOT NULL,

	UNIQUE(serial_passport, number_passport)
);

-- авто
CREATE TABLE taxi_company.cars (
	id SERIAL PRIMARY KEY,
	brand varchar(32) NOT NULL,
	driver_id integer NOT NULL,
	car_class varchar(8) NOT NULL CHECK(car_class = 'economy' OR car_class = 'business'),
	color varchar(20) NOT NULL,
	plate varchar(9) NOT NULL UNIQUE,
	year_release smallint NOT NULL,
	
	FOREIGN KEY(driver_id) REFERENCES taxi_company.drivers(id)
);

-- тарифы
CREATE TABLE taxi_company.tariffs (
	id SERIAL PRIMARY KEY,
	tariff_name varchar(30) NOT NULL,
	day_time varchar(5) NOT NULL CHECK(day_time = 'day' or day_time = 'night'),
	distance varchar(8) NOT NULL CHECK(distance IN ('MKAD', 'out_MKAD', 'region')),
	price_dist int NOT NULL CHECK(price_dist > 0)
);

-- заказы
CREATE TABLE taxi_company.orders (
	id SERIAL PRIMARY KEY,
	order_date date NOT NULL,
	order_time time NOT NULL,
	car_id integer NOT NULL,
	pickup_address varchar(128) NOT NULL,
	dropoff_address varchar(128) NOT NULL,
	passenger_count smallint NOT NULL CHECK(passenger_count > 0),
	way_kilometer integer NOT NULL CHECK(way_kilometer > 0),

	FOREIGN KEY(car_id) REFERENCES taxi_company.cars(id)
);

-- инфо об оплате
CREATE TABLE taxi_company.paycheck (
	id SERIAL PRIMARY KEY,
	order_id integer NOT NULL,
	tariff_id integer NOT NULL,
	total_way integer NOT NULL,
	price integer NOT NULL CHECK(price > 0),
	is_paid boolean NOT NULL DEFAULT FALSE, -- в описании кейса не было сказано про статус, но на всякий случай добавлю 

	UNIQUE(order_id, tariff_id), -- защита от дублирования записи

	FOREIGN KEY(order_id) REFERENCES taxi_company.orders(id),
	FOREIGN KEY(tariff_id) REFERENCES taxi_company.tariffs(id)
);