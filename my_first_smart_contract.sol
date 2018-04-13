/* 
*	author f1est
*	telegram: @F1estas (https://t.me/F1estas)	
*/

pragma solidity ^0.4.18;

contract Owned {
	address owner;
	
	function Owned() public {	// конструктор
		owner = msg.sender;
	}

    modifier only_owner() {
		require(msg.sender == owner);
		_;
    }
}

contract Human is Owned {
	bytes32 salt;		// криптографическая соль. В реальных проектах конечно же следует применять динамическую соль,
					// но для тестового задания я буду использовать статическую, чтобы не усложнять реализацию
	bytes32 first_name;
	bytes32 last_name;
	bytes32 passport;
	bytes32 registration;
//  and other requisites
	
	event debug_showOwner_Human(address,address,address);
	
	function Human(bytes32 _salt) public {
		salt = _salt;
		emit debug_showOwner_Human(msg.sender,owner,this);
	}	

	function fill_all(bytes32 fname, bytes32 lname, bytes32 _passport, bytes32 _reg) public only_owner {
		set_first_name(fname);
		set_last_name(lname);
		set_passport(_passport);
		set_registraion(_reg);
	}

	function set_first_name(bytes32 name) public only_owner {
		first_name = sha256(name, salt);
	}

	function set_last_name(bytes32 name) public only_owner{
		last_name = sha256(name, salt);
	}

	function set_passport(bytes32 _passport) public only_owner {
		passport = sha256(_passport, salt);
	}

	function set_registraion(bytes32 _registation) public only_owner {
		registration = sha256(_registation, salt);
	}
	
	// оставим возможность проверить данные человека
	function is_person(bytes32 fname, bytes32 lname, bytes32 _passport, bytes32 _reg) public view returns(bool) {

		if(first_name == sha256(fname, salt) &&
		   last_name == sha256(lname, salt) &&
		   passport == sha256(_passport, salt) &&
		   registration == sha256(_reg, salt))
			return true;

		return false;
	}
}

/*
contract Seller is Owned, Human("_1q2w3e4r5t") {
	function fill() public only_owner {	// для быстрого заполнения реквизитов, используется только в тестовом задании
		set_first_name("Ivan");
		set_last_name("Pupkin");
		set_passport("0101112233");
		set_registraion("Moskow city, Lenina st,1/8");
	}
}
contract Buyer is Owned, Human("1a2s3d4f5g_") {
	function fill() public only_owner {	// для быстрого заполнения реквизитов, используется только в тестовом задании
		set_first_name("Peter");
		set_last_name("Romanov");
		set_passport("0001001122");
		set_registraion("St.Peterspurg, Dvorcovaya nab. 38");
	}
}
*/

contract Object is Owned{
    
	struct Rightholder {
		address	human;				// правообладатель на объект (пример: "Пупкин Иван Иванович").
									// т.к. в сделке уже имеются контракты всех участников сделки, 
									// достаточно хранить адрес указывающий на контракт владельца
//		string	name; 				// правообладатель на объект (пример: "Пупкин Иван Иванович"). 
// NOTE: т.к. заперщено хранить персональные данные в "чистом" виде name не использую
		bytes32	registration;		// вид, номер и дата регистрации права (пример: "Собственность, № 50-50-08/111/2002-101 от 01.02.2002")
		bytes32	restriction;		// ограничение (обременение) права (пример: "не зарегистрировано")
		bool	b_no_restriction;	// это даст возможность легче/дешевле проверять ограничения
    }

	Rightholder[] public rightholders;	// правообладатели
	Rightholder[] public former_rightholders;	// предшествующие правообладатели. В этот параметр будет копироваться параметр rightholders 
										// в момент создания сделки, для возможности отмены сделки, т.к. в случае отмены сделки 
										// правообладатели должны остаться прежние
    int8 public num_of_storeys;			// этажность (пример: 2)
    uint16 public rooms_on_floor;		// номера на поэтажном плане
	uint24 public square;				// площадь объекта (пример: 60.1 (кв.м))
	bytes32 public cadastral_number;		// кадастровый (или условный) номер объекта (пример: "50:11:0050609")
	bytes32 public name;					// наименование объекта (пример: "Квартира")
	bytes32 public use;					// назначение объекта (пример: "Жилое")
	bytes32 public inventory_number;		// инвентарный номер, литер
	bytes32 public obj_address;			// адрес объекта (пример: "г.Москва ул.Ленина, д.1 кв.8")
    bytes32 public composition;			// состав (???)
    bytes32 public shared_constr_agreement;	// договоры участия в долевом строительстве (пример: "не зарегистрировано")
	bytes32 public claims;				// правопритязания (пример: "отсутствуют")
    bytes32 public claimed_claims;		// заявленные в судебном порядке права требования (пример: "данные отсутствуют")

// WARNING!!! Возможно параметры shared_constr_agreement, claims и claimed_claims (или какой-то из них) при перепродаже объекта
// также требуют обновления как и в случае с rightholders (т.е. резервное копирование и очистка значений при создании объекта 
// и восстановление в случае отмены сделки)

	event debug_showOwner_Object(address,address,address);

	function Object()public {
		emit debug_showOwner_Object(msg.sender,owner,this);
	}

	function add_rightholder(Human _human, bytes32 _registation, bytes32 _restriction) public only_owner {
		bool b_no_restriction;

		bytes32 str_no_restr = 0xd0bdd0b520d0b7d0b0d180d0b5d0b3d0b8d181d182d180d0b8d180d0bed0b2d0; // "не зарегистрировано" -> bytes32
		
//		if(keccak256(_restriction) == keccak256(str_no_restr))
		if(keccak256(_restriction) == keccak256(str_no_restr))
			b_no_restriction = true;

		rightholders.push(Rightholder(_human,_registation,_restriction,b_no_restriction));
	}


	function fill_other_requisites(/* set all other requisites */) public view /* view must be removed */ only_owner {
/*
		TODO: fill other requisites
*/
	}
/*
	function copy_object(Object other) public only_owner {
		copy_rightholders(other.rightholders, rightholders);
		num_of_storeys = other.num_of_storeys;
		rooms_on_floor = other.rooms_on_floor;
		square = other.square;
		cadastral_number = other.cadastral_number;
		name = other.name;
		use = other.use;
		inventory_number = other.inventory_number;
		obj_address = other.obj_address;
		composition = other.composition;
		shared_constr_agreement = other.shared_constr_agreement;
		claims = other.claims;
		claimed_claims = other.claimed_claims;
	}
*/

	function copy_object(Object other) public only_owner {
		backup_rightholders();
		free_rightholders();
		copy_rightholders(other);
		set_num_of_storeys(other.get_num_of_storeys());
		set_rooms_on_floor(other.get_rooms_on_floor());
		set_square(other.get_square());
		set_cadastral_number(other.get_cadastral_number());
		set_name(other.get_name());
		set_use(other.get_use());
		set_inventory_number(other.get_inventory_number());
		set_obj_address(other.get_obj_address());
		set_composition(other.get_composition());
		set_shared_constr_agreement(other.get_shared_constr_agreement());
		set_claims(other.get_claims());
		set_claimed_claims(other.get_claimed_claims());
	}


	function set_num_of_storeys(int8 num) public only_owner {num_of_storeys = num;}
	function set_rooms_on_floor(uint16 rooms) public only_owner {rooms_on_floor = rooms;}
	function set_square(uint24 sq) public only_owner {square = sq;}
	function set_cadastral_number(bytes32 cadastr_num) public only_owner {cadastral_number = cadastr_num;}
	function set_name(bytes32 _name) public only_owner {name = _name;}
	function set_use(bytes32 _use) public only_owner {use = _use;}
	function set_inventory_number(bytes32 _inventory_number) public only_owner {inventory_number = _inventory_number;}
	function set_obj_address(bytes32 _obj_address) public only_owner {obj_address = _obj_address;}
	function set_composition(bytes32 _composition) public only_owner {composition = _composition;}
	function set_shared_constr_agreement(bytes32 _shared_constr_agreement) public only_owner {shared_constr_agreement = _shared_constr_agreement;}
	function set_claims(bytes32 _calims) public only_owner {claims = _calims;}
	function set_claimed_claims(bytes32 _calims) public only_owner {claimed_claims = _calims;}

	function get_num_of_storeys() public view returns(int8){return num_of_storeys;}
	function get_rooms_on_floor() public view returns(uint16){return rooms_on_floor;}
	function get_square() public view returns(uint24){return square;}
	function get_cadastral_number() public view returns(bytes32){return cadastral_number;}
	function get_name() public view returns(bytes32){return name;}
	function get_use() public view returns(bytes32){return use;}
	function get_inventory_number() public view returns(bytes32){return inventory_number;}
	function get_obj_address() public view returns(bytes32){return obj_address;}
	function get_composition() public view returns(bytes32){return composition;}
	function get_shared_constr_agreement() public view returns(bytes32){return shared_constr_agreement;}
	function get_claims() public view returns(bytes32){return claims;}
	function get_claimed_claims() public view returns(bytes32){return claimed_claims;}

	function get_rightholders_length() public view returns(uint) {return rightholders.length;}
	function get_rightholder_human_by_index(uint index) public view returns(address) {return rightholders[index].human;}
	function get_rightholder_registration_by_index(uint index) public view returns(bytes32) {return rightholders[index].registration;}
	function get_rightholder_restriction_by_index(uint index) public view returns(bytes32) {return rightholders[index].restriction;}
	function get_rightholder_brestriction_by_index(uint index) public view returns(bool) {return rightholders[index].b_no_restriction;}


	function copy_rightholders(Rightholder[] from, Rightholder[] storage to) private only_owner {
		for(uint i = 0; i < from.length; i++) {
			to.push(Rightholder(from[i].human, from[i].registration, from[i].restriction, from[i].b_no_restriction));
		}
	}

	function copy_rightholders(Object from_object) public only_owner {
		uint length = from_object.get_rightholders_length();

		for(uint i = 0; i < length; i++) {
			rightholders.push(Rightholder(from_object.get_rightholder_human_by_index(i),
								from_object.get_rightholder_registration_by_index(i),
								from_object.get_rightholder_restriction_by_index(i),
								from_object.get_rightholder_brestriction_by_index(i)));
		}
	}

	function backup_rightholders() public only_owner {
		free_backup();
		copy_rightholders(rightholders,former_rightholders);
	}

	function restore_rightholders() public only_owner {
		free_rightholders();

		copy_rightholders(former_rightholders, rightholders);

		free_backup();
	}
	
	function free_rightholders() public only_owner {
		delete rightholders;
	}

	function free_backup() public only_owner {
		delete former_rightholders;
	}
}

contract Selling is Owned {
/*
*   во всех методах контракта, в качестве параметра key - подразумевается кадастровый номер объекта 
*/
	using Deals for Deals.itmap;
	Deals.itmap deals;

	event debug_printDeal(Deals.Record deal, uint map_size, uint total_key);
	event debug_showOwner_Selling(address,address,address);

	event Created();
	event Signed();
	event InProcess();
	event Executed();
	event Aborted();

	function deal_check(bytes32 key) public view returns(Deals.State state) {
		return deals.get_state(key);
	}

	// создание сделки
	function create(bytes32 key, uint cost) public only_owner returns(Deals.State state){
		require(cost > 0);
		
		// если по данному оъекту уже совершались сделки создадим новую сделку на основе последней
		// т.е. копируем реквизиты объекта из последней сделки
		if(deals.exist(key)) {
			state = deals.insert(key,cost,deals.get_last(key));
		}
		// иначе создае новый объект
		else
			state = deals.insert(key, cost);

		emit debug_printDeal(deals.get_last(key), deals.keysNames.length, deals.get_num_of(key));
		emit debug_showOwner_Selling(msg.sender,owner,this);

		emit Created();
	}

	// передаются подписи двух клиентов	(по	сути отпечатки ЭЦП), меняет	состояние на "Подписан".	
	function set_signature(bytes32 key, bytes32 ds_seller, bytes32 ds_buyer) public only_owner returns (Deals.State state) {
		Deals.State _state = deals.get_state(key);
		require(_state == Deals.State.created);
/*
			... do something with ds_seller and ds_buyer ...
*/
		emit Signed();
		return deals.set_state(key, Deals.State.signed);
	}

	// меняет состояние,	Х	–	с	"подписан"	на	"в процессе исполнения",
	// Y - с "в	процессе исполнения" на "исполнен"
	function change_state_deal(bytes32 key) public only_owner returns (Deals.State state)	{
		Deals.State _state = deals.get_state(key);
		require(_state == Deals.State.signed || _state == Deals.State.pending);

		if(_state == Deals.State.signed) {
			emit InProcess();
			return deals.set_state(key, Deals.State.pending);
		}

		else if(_state == Deals.State.pending) {
			emit Executed();
			return deals.set_state(key, Deals.State.executed);
		}

		return deals.get_state(key);
	}

	function cancel_deal(bytes32 key) public only_owner returns (Deals.State state) {
		state = deals.cancelling(key);
		emit Aborted();
	}

/*
	function get_deal(bytes32 key) public view returns(uint total_deals, uint total_key_deals, Deals.State state) {
		 var deal = deals.get_last(key);
		
			... do something with deal...
		 return (deals.keysNames.length, deals.get_num_of(key), deal.state);
	}
*/

/*
	// получить всю историю сделок по объекту
	function get_all_deals(bytes32 key) public view returns (uint){
		uint total = deals.get_num_of(key);
		
		for(uint i = 0; i < total; i++) {
			var deal = deals.get_by_index(key,i)

			... do something with deal...
		}
		return total;
	}
*/
}

library Deals {

    enum State {
		inactive,	// не активна (сделка не была создана или была отменена)
		created,	// создана				
		signed,		// подписана
		pending,	// в процессе исполнения	
		executed	// исполнена
	}

	struct Record {
		bool exists;
		State state;
		uint cost;		// стоимость объекта
		Human seller;
		Human buyer;
		Object object;
	}
	
	struct itmap {
		mapping(bytes32 => Record[]) data;
		bytes32[] keysNames;
	}
	
	function base_insert(itmap storage self, bytes32 key, uint cost, Object obj) internal returns (State) {

		if (self.data[key].length == 0) {
			// добавим очередной ключ к списку ключей
			self.keysNames.push(key);
		}
		else {
			// Поскольку объект не должен продаваться одновременно нескольим лицам,
			// проверяем есть ли незавершенная сделка с данным объектом.
			// Т.к. объект может быть перепродан несколько раз,
			// нужно пройти по всем сделкам с данным объектом
			// TODO: тут можно обойтись без цикла, проверяя только последний элемент
			uint recordsLen = self.data[key].length;
			
			for(uint i = 0; i < recordsLen; i ++) {

				if(self.data[key][i].exists) {
					Deals.State state = self.data[key][i].state;
					require(state == Deals.State.inactive || state == Deals.State.executed);
				}
				else continue;
			}
		}
		
		self.data[key].push(Record(true, 
								  State.created,
								  cost,
								  new Human("_1q2w3e4r5t"),		// для теста я буду использовать статическую криптосоль, чтобы не усложнять реализацию
								  new Human("1a2s3d4f5g_"),		// для теста я буду использовать статическую криптосоль, чтобы не усложнять реализацию
								  obj
								  ));
		return get_state(self, key); 
	}

	// новая сделка с новым объектом по которому еще небыло сделок
	function insert(itmap storage self, bytes32 key, uint cost) internal returns (State) {
		Object new_object = new Object();
		
		new_object.set_cadastral_number(key);
		new_object.fill_other_requisites();
		
		return  base_insert(self, key, cost, new_object);
	}

	// новая сделка на основе существующей
	function insert(itmap storage self, bytes32 key, uint cost, Record exist_record) internal returns (State) {
		Object updated_object = new Object();
		
		updated_object.copy_object(exist_record.object);
		updated_object.backup_rightholders();
		updated_object.free_rightholders();
		

// WARNING!!! Возможно в контракте Object, параметры shared_constr_agreement, claims и claimed_claims (или какой-то из них) при перепродаже объекта
// также требуют обновления как и в случае с rightholders (т.е. резервное копирование и очистка значений при создании объекта 
// и восстановление в случае отмены сделки)
		
		return base_insert(self, key, cost, updated_object);
	}

	// проверить наличие сделок по данному объекту 
	function exist(itmap storage self, bytes32 key) public view returns (bool) {
		if (self.data[key].length != 0 && self.data[key][self.data[key].length - 1].exists)
			return true;

		return false;
	}

	// получить общее количество (в том числе и не завршенную) сделок с данным объектом
	function get_num_of(itmap storage self, bytes32 key) public view returns (uint) {
		return self.data[key].length;
	}
	
	// получить значение по индексу
	function get_by_index(itmap storage self, bytes32 key, uint index) internal view returns (Record) {
		require(self.data[key][index].exists == true);
		return self.data[key][index];
	}
	
	// получить последнюю (единственную активную, если она еще активна) сделку
	function get_last(itmap storage self, bytes32 key) internal view returns (Record last) {
		uint recordsLen = self.data[key].length;

		require(self.data[key][recordsLen - 1].exists == true);
		last = self.data[key][recordsLen - 1];
	}

	// получить состояние сделки
	function get_state(itmap storage self, bytes32 key) public view returns (State) {
		return get_last(self, key).state;
	}

	// установить новое состояние сделки
	function set_state(itmap storage self, bytes32 key, State state) internal returns (State) {
		uint recordsLen = self.data[key].length;

		require(self.data[key][recordsLen - 1].exists == true);
		self.data[key][recordsLen - 1].state = state;
		return self.data[key][recordsLen - 1].state;
	}
	
	// Т.к. необходимо хранить все сделки совершенные через	смарт-контракт, 
	// то реализация удаления сделки из хранилища не предусматривается.
	// Вместо этого добавим процедуру отмены сделки
	function cancelling(itmap storage self, bytes32 key) internal returns(State) {
		uint recordsLen = self.data[key].length;

		require(self.data[key][recordsLen - 1].exists == true 
				&& self.data[key][recordsLen - 1].state != State.inactive
				&& self.data[key][recordsLen - 1].state != State.executed);

		// восстановим прежних правообладателей
		self.data[key][recordsLen - 1].object.restore_rightholders();
/*
TODO: return back money minus commision?!
*/
		self.data[key][recordsLen - 1].state = State.inactive;
		return get_state(self, key);
	}
}
