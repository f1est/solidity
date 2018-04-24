Смарт-котракт реализующий сделку купли-продажи недвижимости. Смарт-контракт работает только	 с тем адресом от которого был создан, а также хранит все сделки, совершенные через него.	

Сценарий работы со смарт-контрактом:
1) Создается экземпляр контракта Selling. 
2) Создаются экземпляры контракта Human для продавца и покупателя с указанием обязательных полей:
	bytes32 salt - (криптосоль)
	address _trustee -	адрес доверенного лица проводящего сделку, в данном случае сюда нужно передать адрес объекта Selling, созданного на этапе 1. 
						Это необходимо, чтобы была возможность отправить срества за покупаемый объект с адреса buyer'а от имени контракта Selling по завершении сделки.
2.1) Заполняем необходимые поля(реквизиты).
3) Создается экземпляр контракта Object с указанием обязательных полей:
	bytes32 cadastr_num - кадастровый номер объекта, который будет являться ключем для дальнейшего поиска объекта среди прочих сделок. 
	address _trustee - адрес доверенного лица, в данном случае сюда нужно передать адрес объекта Selling, созданного на этапе 1 
3.1) Заполняются реквизиты объекта.
4) Проводится сделка (в перечисленных методах все аргументы обязательны. Порядок аргументов должен соответствовать):
4.1) Создается сделка методом create() в контракте Selling (созданном на этапе 1), с передачей следующих аргументов:
	uint256 cost - стоимость объекта
	address seller - адрес продавца (адрес созданного ранее экземляра контракта Human для продавца) 
	address buyer - адрес покупателя (адрес созданного ранее экземляра контракта Human для покупателя)
	address object - адрес объекта (адрес созданного ранее экземляра контракта Object)
4.2) Подписание сделки с передачей ключей клиентов методом set_signature(). Аргументы следующие:
	address object - адрес объекта
	bytes32 ds_seller - отпечаток ЭЦП продавца
	bytes32 ds_buyer - отпечаток ЭЦП покупателя
4.3) Изменение состояния сделки методом сhange_state_deal(). Параметры метода:
	address object - адрес объекта
	Метод сам определяет в какое состояние перевести сделку, на основе того состояния в котором он находится на данный момент:
	При первом вызове этого метода сделка переходит в состояние "В процессе исполнения"
	При повторном вызове сделка перейдет в состояние "Исполнен" при этом на адресе buyer должно быть необходимое количество средств (не менее cost, указанный на этапе 4.1 во время создания сделки), которые  автоматически будут переведены на адрес seller'а. После этого правообладатель объекта будет изменен на покупателя (buyer)
4.4) Дополнение реквизитов нового правообладателя, а именно "вид, номер и дата регистрации права" вызовом метода set_registration_for_rightholder() со следующими аргументами:
	address object - адрес объекта
	bytes32	_registration - строка содержащая "вид, номер и дата регистрации права"
4.5) При необходимости добавляются дополнительные правообладатели к объекту вызовом метода add_rightholder(). Аргументы:
	address object - адрес объекта
	address _human - адрес еще одного покупателя (адрес созданного ранее экземляра контракта Human для покупателя)
	bytes32 _registration - строка содержащая "вид, номер и дата регистрации права"
	bytes32 _restriction - строка содержащая данные об ограничении (обременении) права 

Вспомогательные методы контракта Selling:
deal_check() - проверка сделки по реквизитам. В качестве реквизитов принимает адрес экземпляра контракта Object, созданного на этапе 3. Возвращает статус сделки.
deal_cancell() - отмена сделки. Сделка может быть отменена на любой стадии до передачи средств и смене правообладателя (т.е. до смены статуса на "Исполнен").

Все остальное прокомментировано по листингу программы.


Из недоделанного:
Не реализована проверка объекта (коммунальные задолженности, отсутствие зарегистрированных жильцов и т.п), т.к. не до конца понятно как это должно быть реализовано на blockchain'е.
В выполнении тестового задания используется bytes32 вместо string. Поэтому нужно учитывать ограничение длины строки, особенно в кирилице
Не оптимизировано, некоторые некритичные ошибки умышленно не исправлялись, т.к. задание тестовое (к примеру строковые данные пеобразуются в bytes32 с отсечением символов не вместившихся в максимальную длину типа bytes32).

