/* 
*	author		f1est
*	telegram:	@F1estas (https://t.me/F1estas)
*	e-mail:		www-b@mail.ru
*/

pragma solidity ^0.4.18;

contract Owned {
	address owner;
	address internal trustee;
	
	function Owned() public {	// конструктор
		owner = msg.sender;
	}
	
	function set_trustee(address _trustee) internal only_owner {
		trustee = _trustee;
	}
	
	function get_owners() internal view returns(address _owner, address _trustee) {
		return (owner,trustee);
	}
    
	modifier only_owner() {
		require(msg.sender == owner || msg.sender == trustee);
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
	
	event Debug_showOwner_Human(address,address,address);
	
	function Human(bytes32 _salt) public {
		require(_salt[0] != 0);		// проверим, что вводимое значение не пустое
		salt = keccak256(_salt);
		emit Debug_showOwner_Human(msg.sender,owner,this);
	}	

	function fill_all(string fname, string lname, string _passport, string _reg) public only_owner {
		set_first_name(fname);
		set_last_name(lname);
		set_passport(_passport);
		set_registraion(_reg);
	}

	function set_first_name(string name) public only_owner {
		require(Deals.utfStringLength(name) > 0);
		first_name = sha256(name, salt);
	}

	function set_last_name(string name) public only_owner{
		require(Deals.utfStringLength(name) > 0);
		last_name = sha256(name, salt);
	}

	function set_passport(string _passport) public only_owner {
		require(Deals.utfStringLength(_passport) > 0);
		passport = sha256(_passport, salt);
	}

	function set_registraion(string _registration) public only_owner {
		require(Deals.utfStringLength(_registration) > 0);
		registration = sha256(_registration, salt);
	}
	
	// оставим возможность проверить данные человека
	function is_person(string fname, string lname, string _passport, string _reg) public view returns(bool) {

		if(first_name == sha256(fname, salt) &&
		   last_name == sha256(lname, salt) &&
		   passport == sha256(_passport, salt) &&
		   registration == sha256(_reg, salt))
			return true;

		return false;
	}
}

contract Object is Owned{
    
	struct Rightholder {
		address	human;				// правообладатель на объект (пример: "Пупкин Иван Иванович").
//		string	name; 				// правообладатель на объект (пример: "Пупкин Иван Иванович"). 
// NOTE: т.к. заперщено хранить персональные данные в "чистом" виде name не использется
		bytes32	registration;		// вид, номер и дата регистрации права (пример: "Собственность, № 50-50-08/111/2002-101 от 01.02.2002")
		uint32	timestamp;			// 
		bytes32	restriction;		// ограничение (обременение) права (пример: "не зарегистрировано")
		bool	b_no_restriction;	// это даст возможность легче/дешевле проверять ограничения
    }

	Rightholder[] public rightholders;	// правообладатели
//	Rightholder[] public former_rightholders;	// предшествующие правообладатели. В этот параметр будет копироваться параметр rightholders 
										// в момент создания сделки, для возможности отмены сделки, т.к. в случае отмены сделки 
										// правообладатели должны остаться прежние
    int8 public num_of_storeys;			// этажность (пример: 2)
    uint16 public rooms_on_floor;		// номера на поэтажном плане
	uint24 public square;				// площадь объекта (пример: 60.1 (кв.м))
	bytes32 public cadastral_number;		// кадастровый (или условный) номер объекта (пример: "50:11:0050609")
	bytes32 public name;				// наименование объекта (пример: "Квартира")
	bytes32 public use;					// назначение объекта (пример: "Жилое")
	bytes32 public inventory_number;	// инвентарный номер, литер
	bytes32 public obj_address;			// адрес объекта (пример: "г.Москва ул.Ленина, д.1 кв.8")
    bytes32 public composition;			// состав (???)
    bytes32 public shared_constr_agreement;	// договоры участия в долевом строительстве (пример: "не зарегистрировано")
	bytes32 public claims;				// правопритязания (пример: "отсутствуют")
    bytes32 public claimed_claims;		// заявленные в судебном порядке права требования (пример: "данные отсутствуют")

// WARNING!!! Возможно параметры shared_constr_agreement, claims и claimed_claims (или какой-то из них) при перепродаже объекта
// также требуют обновления как и в случае с rightholders (т.е. резервное копирование и очистка значений при создании объекта 
// и восстановление в случае отмены сделки)

	event Debug_showOwner_Object(address,address,address);
	event Added_Rightholder(address human);

	function Object(bytes32 cadastr_num, address _trustee) public { // обязательное требование - кадастровый номер объекта, т.к. это один из ключевых параметров проведения сделки
		require(cadastr_num[0] != 0 &&  _trustee != address(0)); // проверим, что вводимое значение не пустое
		set_cadastral_number(cadastr_num);
		set_trustee(_trustee);

		emit Debug_showOwner_Object(msg.sender,owner,this);
	}

	function add_rightholder(address _human, bytes32 _registration, bytes32 _restriction) public only_owner {
		bool b_no_restriction;
		bytes32 str_no_restr = 0xd0bdd0b520d0b7d0b0d180d0b5d0b3d0b8d181d182d180d0b8d180d0bed0b2d0; // строка "не зарегистрировано" в формате bytes32 (обрезана!!!)
	
		require(_human != address(0)); // проверим, что вводимые значения не пустые

		if(_restriction == str_no_restr || _restriction[0] == 0) // если обременений нет поставим соответсвующий флаг
			b_no_restriction = true;

		rightholders.push(Rightholder(_human, _registration, uint32(now), _restriction, b_no_restriction));

		emit Added_Rightholder(_human);
	}


	function fill_other_requisites(/* set all other requisites */) public view /* view must be removed */ only_owner {
/*
		TODO: fill other requisites
*/
	}

	function set_num_of_storeys(int8 num) public only_owner {num_of_storeys = num;}
	function set_rooms_on_floor(uint16 rooms) public only_owner {rooms_on_floor = rooms;}
	function set_square(uint24 sq) public only_owner {square = sq;}
	function set_cadastral_number(bytes32 cadastr_num) public only_owner {
		require(cadastr_num[0] != 0);		// проверим, что вводимое значение не пустое
		cadastral_number = cadastr_num;
	}
	function set_name(bytes32 _name) public only_owner {name = _name;}
	function set_use(bytes32 _use) public only_owner {use = _use;}
	function set_inventory_number(bytes32 _inventory_number) public only_owner {inventory_number = _inventory_number;}
	function set_obj_address(bytes32 _obj_address) public only_owner {obj_address = _obj_address;}
	function set_composition(bytes32 _composition) public only_owner {composition = _composition;}
	function set_shared_constr_agreement(bytes32 _shared_constr_agreement) public only_owner {shared_constr_agreement = _shared_constr_agreement;}
	function set_claims(bytes32 _calims) public only_owner {claims = _calims;}
	function set_claimed_claims(bytes32 _calims) public only_owner {claimed_claims = _calims;}
	function set_registration_for_last_rightholder(bytes32 _registration) public only_owner {
		uint length = rightholders.length;
		rightholders[length - 1].registration = _registration;
	}

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

/*
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
	
	function free_backup() public only_owner {
		delete former_rightholders;
	}
*/
	function free_rightholders() public only_owner {
		delete rightholders;
	}

}

contract Selling is Owned {
/*
*   во всех методах контракта, в качестве параметра key - подразумевается кадастровый номер объекта 
*/
	using Deals for Deals.itmap;
	Deals.itmap deals;

	event Debug_printDeal(Deals.Record deal, uint map_size, uint total_key);
	event Debug_showOwner_Selling(address,address,address);

	event Created();
	event Signed();
	event InProcess();
	event Executed();

	function deal_check(address obj) public view returns(Deals.State state) {
		return deals.get_state(Deals.get_key(obj));
	}

	// создание сделки
	function create(uint cost, address seller, address buyer, address object) public only_owner returns(Deals.State state){
		// проверим, что вводимые значения не пустые
		require(cost > 0 && 
				seller != address(0) && 
				buyer != address(0) && 
				object != address(0)); 
/*		
		// проверим не продает ли продавец самому себе
		require(Human(seller).get_owner() != Human(buyer).get_owner());

		// проверим, что owner продавца и owner объекта совпадают
		require(Human(seller).get_owner() == Object(object).get_owner());
		
		// проверим, что owner проводящего сделку (Selling) и owner объекта совпадают
		require(get_owner() == Object(object).get_owner());
*/

		bytes32 key = Deals.get_key(object);
/*		
		// если по данному оъекту уже совершались сделки создадим новую сделку на основе последней
		// т.е. копируем реквизиты объекта из последней сделки
		if(deals.exist(key)) {
			state = deals.insert(key,cost,deals.get_last(key));
		}
		// иначе создае новый объект
		else
*/
			state = deals.insert(cost, seller, buyer, object);

		emit Debug_printDeal(deals.get_last(key), deals.keysNames.length, deals.get_num_of(key));
		emit Debug_showOwner_Selling(msg.sender,owner,this);

		emit Created();
	}

	// передаются подписи двух клиентов	(по	сути отпечатки ЭЦП), меняет	состояние на "Подписан".	
	function set_signature(address object, bytes32 ds_seller, bytes32 ds_buyer) public only_owner returns (Deals.State state) {
		require(object != address(0) &&
				ds_seller[0] != 0 &&
				ds_buyer[0] != 0); // проверим, что вводимые значения не пустые
		
		bytes32 key = Deals.get_key(object);
		Deals.State _state = deals.get_state(key);
		
		require(_state == Deals.State.created);
/*
			... do something with ds_seller and ds_buyer ...
*/
		emit Signed();
		return deals.set_state(key, Deals.State.signed);
	}

	// меняет состояние, с "подписан" на "в процессе исполнения",
	// с "в	процессе исполнения" на "исполнен"
	function change_state_deal(address object) public only_owner returns (Deals.State state)	{
		bytes32 key = Deals.get_key(object);
		Deals.State _state = deals.get_state(key);
		
		require(_state == Deals.State.signed || _state == Deals.State.pending);

		if(_state == Deals.State.signed) {
/*
			... do something ...
*/
			emit InProcess();
			return deals.set_state(key, Deals.State.pending);
		}

		else if(_state == Deals.State.pending) {
			deals.sold(key); //передача прав собственности

			emit Executed();
			return deals.set_state(key, Deals.State.executed);
		}

		return deals.get_state(key);
	}

	function set_registration_for_rightholder(address object, bytes32 _registration) public only_owner {
		bytes32 key = Deals.get_key(object);
		Object obj = Object(deals.get_last(key).object);
		
		obj.set_registration_for_last_rightholder(_registration);
	}

	function add_rightholder(address object, address _human, bytes32 _registration, bytes32 _restriction) public only_owner {
		bytes32 key = Deals.get_key(object);
		Object obj = Object(deals.get_last(key).object);

		obj.add_rightholder(_human,_registration,_restriction);		
	}
/*
	event Aborted();
	function cancel_deal(string key) public only_owner returns (Deals.State state) {
		state = deals.cancelling(key);
		emit Aborted();
	}
*/
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
		address seller;
		address buyer;
		address object;
	}
	
	struct itmap {
		mapping(bytes32 => Record[]) data;
		bytes32[] keysNames;
	}
	
	function base_insert(itmap storage self, uint cost, address seller, address buyer, address obj) private returns (State) {

		Object object = Object(obj);
		bytes32 key = object.get_cadastral_number(); 
		
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
								  seller,	
								  buyer,	
								  obj
								  ));
		return get_state(self, key); 
	}

	// новая сделка с новым объектом по которому еще небыло сделок
	function insert(itmap storage self, uint cost, address seller, address buyer, address object) internal returns (State) {
		return  base_insert(self, cost, seller, buyer, object);
	}
/*
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
*/

	// получить ключ (кадастровый номер) объекта
	function get_key(address object) public view returns (bytes32 key) {
		require(object != address(0));
		return Object(object).get_cadastral_number();
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
		return get_last(self,key).state;
	}

	// передча прав собственности
	function sold(itmap storage self, bytes32 key) internal {
		Object obj = Object(get_last(self, key).object);
		obj.free_rightholders();

// TODO: сформировать правильный параметр _registration (вид, номер и дата регистрации права (пример: "Собственность, № 50-50-08/111/2002-101 от 01.02.2002")))
		obj.add_rightholder(get_last(self, key).buyer,	// новый правообладатель
							"",							// заполним дату регистрации позже вызовом функции set_registration_for_rightholder()
							0);
	}

/*
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
// TODO: return back money minus commision?!
		self.data[key][recordsLen - 1].state = State.inactive;
		return get_state(self, key);
	}
*/
	function utfStringLength(string str) public pure returns (uint length)
	{
		uint i=0;
		bytes memory string_rep = bytes(str);
		
		while (i < string_rep.length)	{
			if (string_rep[i]>>7==0)
				i+=1;
			else if (string_rep[i]>>5==0x6)
				i+=2;
			else if (string_rep[i]>>4==0xE)
				i+=3;
			else if (string_rep[i]>>3==0x1E)
				i+=4;
			else
				//For safety
				i+=1;
				
			length++;
		}
	}
}
