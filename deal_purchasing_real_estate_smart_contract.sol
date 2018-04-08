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

	function set_cadastr_num(string cadastr_num) public only_owner {
		cadastral_number = cadastr_num;
	}
}


contract Deal is Owned {
    enum State {
		inactive,	// не активна (сделка не была создана или была отменена)
		created,	// создана				
		signed,		// подписана
		pending,	// в процессе исполнения	
		executed	// исполнена
    }

     
    Human public seller = new Human("_1q2w3e4r5t");		// для тестового задания я буду использовать статическую криптосоль, чтобы не усложнять реализацию
    Human public buyer = new Human("1a2s3d4f5g_");		// для тестового задания я буду использовать статическую криптосоль, чтобы не усложнять реализацию
    Object public object = new Object();
    uint public value;		// стоимость объекта
    State public state;

	event debug_showOwner_Deal(address,address,address);
	function create() public only_owner returns(State) {
		require(state == State.inactive);
		state = State.created;

		emit debug_showOwner_Deal(msg.sender,owner,this);
		return state;
	}

	function set_signature(bytes32, bytes32) public only_owner returns (State) {
		require(state == State.created);
		state = State.signed;

		return state;
	}

	function change_state_deal() public only_owner returns (State)
	{
		require(state == State.signed || state == State.pending);

		if(state == State.signed)
			state = State.pending;

		else if(state == State.pending)
			state = State.executed;

		return state;
	}
}
contract Selling is Owned {

	using IterableMapping for IterableMapping.itmap;
	IterableMapping.itmap deals;

	event debug_printDeal(Deal deal, bytes32 keccak, uint map_size);
	event debug_showOwner_Selling(address,address,address);

	function create(string cadastr_num) public only_owner {
		deals.insert(cadastr_num);
//		deals.get_last_deal(cadastr_num).create();

		emit debug_printDeal(deals.get_last_deal(cadastr_num), keccak256(cadastr_num), deals.keys.length);
		emit debug_showOwner_Selling(msg.sender,owner,this);
	}

	function get_deal(string key) public view returns(uint, uint, Deal) {
		return (deals.keys.length, deals.get_total_deals(key), deals.get_last_deal(key));
	}

	event debug_show_all_deals(uint total, uint current, Deal deal);		    
	event debug(uint);
	// получить всю историю сделок по объекту
	function get_all_deals(string key) public view returns (uint){
		uint current = deals.get_total_deals(key);
		
		emit debug(current);
		while(current != 0 ) {
			var(size, total, deal) = get_deal(key);
			emit debug_show_all_deals(uint(total), uint(current), Deal(deal));
			current--;
		}
		return deals.get_total_deals(key);
	}
}

library IterableMapping {
	
	struct itmap {
	    mapping(bytes32 => IndexValue) data;
	    KeyFlag[] keys;
	}
	
	struct IndexValue { 
		uint numDeal;	// номер сделки с данным объектом 
		Deal value;		// сама сделка
	}
	struct KeyFlag { bytes32 key; bool completed; }

	event debug_show_counts(uint size, uint keys_length, string key, Deal deal);
	function insert(itmap storage self, string _key) public {
		bytes32 key = keccak256(_key);
		uint numDeal = self.data[key].numDeal;

		if (numDeal > 0) {
			// Поскольку объект не должен продаваться одновременно нескольим лицам,
			// проверяем есть ли незавершенная сделка с данным объектом.
			// Т.к. объект может быть перепродан несколько раз, нужно пройти по всему mapping
			for (uint i = iterate_start(self); iterate_valid(self, i); i = iterate_next(self, i)) {
				Deal.State state = iterate_get(self,i).state();
				require(state == Deal.State.inactive || state == Deal.State.executed);
			}
		}
		
		self.keys.length++;
		self.data[key].value = new Deal();

		self.data[key].numDeal = numDeal + 1;
		self.keys[self.keys.length - 1].key = key;
		emit debug_show_counts(self.keys.length, self.data[key].numDeal, _key, self.data[key].value);
	}
	
	function complete(itmap storage self, string _key) public returns (bool) {
		bytes32 key = keccak256(_key);
		uint numDeal = self.data[key].numDeal;

		if (numDeal == 0) 
			return false;

		self.keys[numDeal - 1].completed = true;
		return true;
	}

	function get_last_deal(itmap storage self, string _key) public view returns (Deal) {
		bytes32 key = keccak256(_key);
		return self.data[key].value;
	}

	// получить количество совершенных (в том числе и не завршенная) сделок с данным объектом
	function get_total_deals(itmap storage self, string _key) public view returns(uint) {
		bytes32 key = keccak256(_key);
		return self.data[key].numDeal;
	}

	// показать адреса всех сделок по данному объекту
	function show_all_deals(itmap storage self, string _key) public view {
		
	}

	function iterate_start(itmap storage self) public view returns (uint) {
		return iterate_next(self, uint(-1));
	}
	
	function iterate_valid(itmap storage self, uint keyIndex) public view returns (bool) {
		return keyIndex < self.keys.length;
	}
	
	function iterate_next(itmap storage self, uint keyIndex) public view returns (uint) {
		keyIndex++;
		while (keyIndex < self.keys.length && self.keys[keyIndex].completed)
			keyIndex++;
		return keyIndex;
	}
	
	function iterate_get(itmap storage self, uint keyIndex) public view returns (Deal) {
		return self.data[self.keys[keyIndex].key].value;
	}

	// Т.к. необходимо хранить все сделки совершенные через	смарт-контракт, 
	// то реализация удаления сделки из mapping не предусматривается.
	// В итоге каждый новый insert будет "стоить" дороже предыдущего 
	// и в конце концов mapping может вырасти до таких размеров, что 
	// стоимость insert'a будет дороже стоимости объекта :)
	
}


/*
    modifier only_buyer() {
		require(msg.sender == buyer);
		_;
    }
    
    modifier only_seller() {
		require(msg.sender == seller);		
		_;
    }
    
    modifier in_state(State _state) {
		require(state == _state);
		_;
    }
    
    function set_value(uint _value) public only_seller {
        value = _value;
    }

    function Selling() public { // конструктор
        seller = msg.sender;
        set_value(10);
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();

    // Отмена сделки и возврат средств.
    // Функция может быть вызванa только продавцом только до того как сделка подписана
    function abort()
        public
        only_seller
        in_state(State.created)
    {
        emit Aborted();
        state = State.inactive;
        seller.transfer(this.balance);
    }
*/
