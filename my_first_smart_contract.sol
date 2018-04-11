/* 
*	author f1est
*	telegram: @F1estas (https://t.me/F1estas)	
*/

pragma solidity ^0.4.18;
//pragma experimental ABIEncoderV2;

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
	string salt;		// криптографическая соль. В реальных проектах конечно же следует применять динамическую соль,
					// но для тестового задания я буду использовать статическую, чтобы не усложнять реализацию
	bytes32 first_name;
	bytes32 last_name;
	bytes32 passport;
	bytes32 registration;
//  and other requisites
	
	event debug_showOwner_Human(address,address,address);
	
	function Human(string _salt) public {
		salt = _salt;
		emit debug_showOwner_Human(msg.sender,owner,this);
	}	

	function fill_all(string fname, string lname, string _passport, string _reg) public only_owner {
		set_first_name(fname);
		set_last_name(lname);
		set_passport(_passport);
		set_registraion(_reg);
	}

	function set_first_name(string name) public only_owner {
		first_name = sha256(name, salt);
	}

	function set_last_name(string name) public only_owner{
		last_name = sha256(name, salt);
	}

	function set_passport(string _passport) public only_owner {
		passport = sha256(_passport, salt);
	}

	function set_registraion(string _registation) public only_owner {
		registration = sha256(_registation, salt);
	}
	
	function get_digital_signature() public view only_owner returns(bytes32 ds) { //		для тесового задания получим ЭЦП клиента из его реквизитов 
		require(first_name[0] != 0);
		require(last_name[0] != 0);
		require(passport[0] != 0);
		require(registration[0] != 0);

		ds = sha256(first_name, last_name, passport, registration);
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
		string name;	// правообладатель на объект (пример: "Пупкин Иван Иванович")
		string registration;	// вид, номер и дата регистрации права (пример: "Собственность, № 50-50-08/111/2002-101 от 01.02.2002")
		string restriction;		// ограничение (обременение) права (пример: "не зарегистрировано")
				// TODO: возможно нужно поменять тип на bool или enum, это даст возможность легче проверять ограничения
    }

	mapping(uint8 => Rightholder) rightholders; // правообладатели
    int8 num_of_storeys;	// этажность (пример: 2)
	uint24 square;	// площадь объекта (пример: 60.1 (кв.м))
    uint16 rooms_on_floor;	// номера на поэтажном плане
	string cadastral_number;	// кадастровый (или условный) номер объекта (пример: "50:11:0050609")
	string name;	// наименование объекта (пример: "Квартира")
	string use;		// назначение объекта (пример: "Жилое")
	string inventory_number;	// инвентарный номер, литер
	string obj_address;		// адрес объекта (пример: "г.Москва ул.Ленина, д.1 кв.8")
    string composition;		// состав (???)
    string shared_constr_agreement;	// договоры участия в долевом строительстве (пример: "не зарегистрировано")
	string claims;	// правопритязания (пример: "отсутствуют")
    string claimed_claims;	// заявленные в судебном порядке права требования (пример: "данные отсутствуют")

	function Object(string cadastr_num) public {
		cadastral_number = cadastr_num;
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

	function create(string key, uint cost) public only_owner returns(Deals.State){
		Deals.State state = deals.insert(key, cost);

		emit debug_printDeal(deals.get_last(key), deals.keysNames.length, deals.get_num_of(key));
		emit debug_showOwner_Selling(msg.sender,owner,this);

		return state;
	}

	function set_signature(string key, bytes32 ds_seller, bytes32 ds_buyer) public only_owner returns (Deals.State) {
		Deals.State state = deals.get_state(key);
		require(state == Deals.State.created);
		deals.set_state(key, Deals.State.signed);

		return deals.get_state(key);
	}

	function change_state_deal(string key) public only_owner returns (Deals.State)
	{
		Deals.State state = deals.get_state(key);
		require(state == Deals.State.signed || state == Deals.State.pending);

		if(state == Deals.State.signed)
			deals.set_state(key, Deals.State.pending);

		else if(state == Deals.State.pending)
			deals.set_state(key, Deals.State.executed);

		return deals.get_state(key);
	}

//	function get_deal(string key) public view returns(uint total_deals, uint total_key_deals, Deals.Record last_deal) {
//		return (deals.keysNames.length, deals.get_num_of(key), deals.get_last(key));
//	}
	function get_deal(string key) public view returns(uint total_deals, uint total_key_deals, Deals.State state) {
		 var deal = deals.get_last(key);
		
/*
			... do something with deal...
*/
		 return (deals.keysNames.length, deals.get_num_of(key), deal.state);
	}

/*
	// получить всю историю сделок по объекту
	function get_all_deals(string key) public view returns (uint){
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
		mapping(string => Record[]) data;
		string[] keysNames;
	}
	
	function insert(itmap storage self, string key, uint cost) internal returns (State) {

		if (self.data[key].length == 0) {
			// добавим очередной ключ к списку ключей
			self.keysNames.push(key);
		}
		else {
			// Поскольку объект не должен продаваться одновременно нескольим лицам,
			// проверяем есть ли незавершенная сделка с данным объектом.
			// Т.к. объект может быть перепродан несколько раз,
			// нужно пройти по всем сделкам с данным объектом
			
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
								  new Object(key)
								  ));
		return get_state(self, key); 
	}
	
	// получить общее количество (в том числе и не завршенную) сделок с данным объектом
	function get_num_of(itmap storage self, string key) public view returns (uint) {
		return self.data[key].length;
	}
	
	// получить значение по индексу
	function get_by_index(itmap storage self, string key, uint index) internal view returns (Record) {
		require(self.data[key][index].exists == true);
		return self.data[key][index];
	}
	
	// получить последнюю (единственную активную) сделку
	function get_last(itmap storage self, string key) internal view returns (Record last) {
		uint recordsLen = self.data[key].length;
		require(self.data[key][recordsLen - 1].exists == true);
		last = self.data[key][recordsLen - 1];
	}

	// получить состояние сделки
	function get_state(itmap storage self, string key) public view returns (State) {
		return get_last(self, key).state;
	}

	// установить новое состояние сделки
	function set_state(itmap storage self, string key, State state) internal returns (State) {
		uint recordsLen = self.data[key].length;
		require(self.data[key][recordsLen - 1].exists == true);
		self.data[key][recordsLen - 1].state = state;
		return self.data[key][recordsLen - 1];
	}
	
	// Т.к. необходимо хранить все сделки совершенные через	смарт-контракт, 
	// то реализация удаления сделки из хранилища не предусматривается.
}
