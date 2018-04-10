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

    function Object(string cadastr_num) public {
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

     
    Human public seller;
    Human public buyer;
    Object public object;
    uint public value;		// стоимость объекта
    State public state;

    event debug_showOwner_Deal(address,address,address);
    function create(string key) public only_owner returns(State) {
	require(state == State.inactive);
	
	seller = new Human("_1q2w3e4r5t");		// для тестового задания я буду использовать статическую криптосоль, чтобы не усложнять реализацию
	buyer = new Human("1a2s3d4f5g_");		// для тестового задания я буду использовать статическую криптосоль, чтобы не усложнять реализацию
	object = new Object(key);

//		state = State.created;

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

    using Deals_storage for Deals_storage.itmap;
    Deals_storage.itmap deals;

    event debug_printDeal(Deal deal, uint map_size, uint total_key);
    event debug_showOwner_Selling(address,address,address);

    function create(string cadastr_num) public only_owner {
        emit debug_showOwner_Selling(msg.sender,owner,this);
	Deal deal = new Deal();
	deal.create(cadastr_num);
        deals.insert(cadastr_num, deal);

	emit debug_printDeal(deals.get_last(cadastr_num), deals.keysNames.length, deals.get_num_of(cadastr_num));
	
    }

    function get_deal(string key) public view returns(uint total, uint total_key, Deal) {
	return (deals.keysNames.length, deals.get_num_of(key), deals.get_last(key));
    }

    event debug_show_all_deals(uint total, uint current, Deal deal);		    
    event debug(uint);
    // получить всю историю сделок по объекту
    function get_all_deals(string key) public view returns (uint){
	uint total = deals.get_num_of(key);
	
	emit debug(total);
	for(uint i = 0; i < total; i++) {
	    emit debug_show_all_deals(uint(total), uint(i), deals.get_by_index(key,i));
	}
	return total;
    }
}

library Deals_storage {

    struct Record {
	bool exists;
	Deal deal;
    }
    
    struct itmap {
	mapping(string => Record[]) data;
	string[] keysNames;
    }
    
    function insert(itmap storage self, string key, Deal value) internal {

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
		Deal.State state; 
		if(self.data[key][i].exists)
		    state = self.data[key][i].deal.state();
		//require(state == Deal.State.executed);
		//require(state == Deal.State.inactive || state == Deal.State.executed);
	    }
	}
	
	self.data[key].push(Record(true, value));
    }
    
    // получить общее количество (в том числе и не завршенную) сделок с данным объектом
    function get_num_of(itmap storage self, string key) public view returns (uint) {
	return self.data[key].length;
    }
    
    // получить значение по индексу
    function get_by_index(itmap storage self, string key, uint index) public view returns (Deal) {
	
	require(self.data[key][index].exists == true);

	return self.data[key][index].deal;
    }
    
    // получить последнюю сделку
    function get_last(itmap storage self, string key) public view returns (Deal last) {
	uint recordsLen = self.data[key].length;
	
	for(uint i = 0; i < recordsLen; i++) {          
	    last = self.data[key][i].deal;
	}
    }
    
    // Т.к. необходимо хранить все сделки совершенные через	смарт-контракт, 
    // то реализация удаления сделки из хранилища не предусматривается.
}