/* 
*	author f1est
*	telegram: @F1estas (https://t.me/F1estas)	
*/

pragma solidity ^0.4.21;

contract Purchase {
	enum State {
		created,	// создана				
		signed,		// подписана
		pending,	// в процессе исполнения	
		executed,	// исполнена
		inactive	// не активна
	}
	struct Rightholder {
		string name;	// правообладатель на объект (пример: "Пупкин Иван Иванович")
		string registration;	// вид, номер и дата регистрации права (пример: "Собственность, № 50-50-08/111/2002-101 от 01.02.2002")
		string restriction;		// ограничение (обременение) права (пример: "не зарегистрировано")
								// TODO: возможно нужно поменять тип на bool или enum, это даст возможность легче проверять ограничения
	}

	struct Requisites_of_object {
		string cadastral_number;	// кадастровый (или условный) номер объекта (пример: "50:11:0050609")
		string name;	// наименование объекта (пример: "Квартира")
		string use;		// назначение объекта (пример: "Жилое")
		uint24 square;	// площадь объекта (пример: 60.1 (кв.м))
		string inventory_number;	// инвентарный номер, литер
		int8 num_of_storeys;	// этажность (пример: 2)
		uint16 rooms_on_floor;	// номера на поэтажном плане
		string address;		// адрес объекта (пример: "г.Москва ул.Ленина, д.1 кв.8")
		string composition;		// состав (???)
		maping (uint8 => Rightholder) rightholders; // правообладатели
		string shared_constr_agreement;	// договоры участия в долевом строительстве (пример: "не зарегистрировано")
		string claims;	// правопритязания (пример: "отсутствуют")
		string claimed_claims;	// заявленные в судебном порядке права требования (пример: "данные отсутствуют")
	}

	uint public value;
	address public seller;
	address public buyer;
	State public state;

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
}
