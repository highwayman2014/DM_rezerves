// +++ Инфостарт Васильев А.Э. 08.11.2021
// #5620 Перенос механизма аналогов номенклатуры из СММ
//
Функция ПолучитьТабЗапасов(Ссылка)
	
	табАналоги = Новый ТаблицаЗначений;
	табАналоги.Колонки.Добавить("Номенклатура",Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	табАналоги.Колонки.Добавить("Аналог",Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	табАналоги.Колонки.Добавить("Количество", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,3, ДопустимыйЗнак.Любой)));
	
	
	Если ПолучитьФункциональнуюОпцию("дмИспользоватьАналоги") Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =  "ВЫБРАТЬ
		                |	асЗаказНарядЗапасы.Номенклатура КАК Номенклатура,
		                |	асЗаказНарядЗапасы.Количество КАК Количество
		                |ПОМЕСТИТЬ втЗапасы
		                |ИЗ
		                |	Документ.асЗаказНаряд.Запасы КАК асЗаказНарядЗапасы
		                |ГДЕ
		                |	асЗаказНарядЗапасы.Ссылка = &Ссылка
		                |
		                |ОБЪЕДИНИТЬ ВСЕ
		                |
		                |ВЫБРАТЬ
		                |	асЗаказНарядМатериалыЗаказчика.Номенклатура,
		                |	асЗаказНарядМатериалыЗаказчика.Количество
		                |ИЗ
		                |	Документ.асЗаказНаряд.МатериалыЗаказчика КАК асЗаказНарядМатериалыЗаказчика
		                |ГДЕ
		                |	асЗаказНарядМатериалыЗаказчика.Ссылка = &Ссылка
		                |;
		                |
		                |////////////////////////////////////////////////////////////////////////////////
		                |ВЫБРАТЬ
		                |	втЗапасы.Номенклатура КАК Номенклатура,
		                |	втЗапасы.Количество КАК Количество,
		                |	ЕСТЬNULL(ЗапасыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток
		                |ПОМЕСТИТЬ втЗапасыЗН
		                |ИЗ
		                |	втЗапасы КАК втЗапасы
		                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ЗапасыНаСкладах.Остатки(
		                |				,
		                |				СтруктурнаяЕдиница = &СтруктурнаяЕдиница
		                |					И Номенклатура В
		                |						(ВЫБРАТЬ
		                |							втЗапасы.Номенклатура КАК Номенклатура
		                |						ИЗ
		                |							втЗапасы КАК втЗапасы
		                |						СГРУППИРОВАТЬ ПО
		                |							втЗапасы.Номенклатура)) КАК ЗапасыНаСкладахОстатки
		                |		ПО втЗапасы.Номенклатура = ЗапасыНаСкладахОстатки.Номенклатура
		                |;
		                |
		                |////////////////////////////////////////////////////////////////////////////////
		                |ВЫБРАТЬ
		                |	АналогиНоменклатуры.Номенклатура КАК Номенклатура,
		                |	АналогиНоменклатуры.Аналог КАК Аналог
		                |ПОМЕСТИТЬ втАналогиВсе
		                |ИЗ
		                |	РегистрСведений.АналогиНоменклатуры КАК АналогиНоменклатуры
		                |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втЗапасыЗН КАК втЗапасыЗН
		                |		ПО АналогиНоменклатуры.Номенклатура = втЗапасыЗН.Номенклатура
		                |;
		                |
		                |////////////////////////////////////////////////////////////////////////////////
		                |ВЫБРАТЬ
		                |	втАналогиВсе.Номенклатура КАК Номенклатура,
		                |	втАналогиВсе.Аналог КАК Аналог,
		                |	ЗапасыНаСкладахОстатки.КоличествоОстаток КАК КоличествоОстаток,
		                |	втЗапасыЗН.Количество КАК Количество,
		                |	ВЫБОР
		                |		КОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток > 0
		                |			ТОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток
		                |		ИНАЧЕ 0
		                |	КОНЕЦ КАК КоличествоРезерв,
		                |	ВЫБОР
		                |		КОГДА ЗапасыНаСкладахОстатки.КоличествоОстаток - ВЫБОР
		                |				КОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток > 0
		                |					ТОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток
		                |				ИНАЧЕ 0
		                |			КОНЕЦ > 0
		                |			ТОГДА ЗапасыНаСкладахОстатки.КоличествоОстаток - ВЫБОР
		                |					КОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток > 0
		                |						ТОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток
		                |					ИНАЧЕ 0
		                |				КОНЕЦ
		                |		ИНАЧЕ 0
		                |	КОНЕЦ КАК КоличествоРасчетное,
						//{[+] Инфостарт А.Васильев 27.12.2021 #6069
						|	ВЫБОР
						|		КОГДА ВЫБОР
						|				КОГДА ЗапасыНаСкладахОстатки.КоличествоОстаток - ВЫБОР
						|						КОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток > 0
						|							ТОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток
						|						ИНАЧЕ 0
						|					КОНЕЦ > 0
						|					ТОГДА ЗапасыНаСкладахОстатки.КоличествоОстаток - ВЫБОР
						|							КОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток > 0
						|								ТОГДА RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток
						|							ИНАЧЕ 0
						|						КОНЕЦ
						|				ИНАЧЕ 0
						|			КОНЕЦ >= втЗапасыЗН.Количество
						|			ТОГДА 0
						|		ИНАЧЕ 1
						|	КОНЕЦ КАК ОстатокПокрываетПотребность
						//} Инфостарт А.Васильев 27.12.2021
		                |ПОМЕСТИТЬ втАналогиОстатки
		                |ИЗ
		                |	РегистрНакопления.ЗапасыНаСкладах.Остатки(
		                |			,
		                |			СтруктурнаяЕдиница = &СтруктурнаяЕдиница
		                |				И Номенклатура В
		                |					(ВЫБРАТЬ
		                |						Аналоги.Аналог
		                |					ИЗ
		                |						втАналогиВсе КАК Аналоги)) КАК ЗапасыНаСкладахОстатки
		                |		ЛЕВОЕ СОЕДИНЕНИЕ втАналогиВсе КАК втАналогиВсе
		                |		ПО (втАналогиВсе.Аналог = ЗапасыНаСкладахОстатки.Номенклатура)
		                |		ЛЕВОЕ СОЕДИНЕНИЕ втЗапасыЗН КАК втЗапасыЗН
		                |		ПО (втАналогиВсе.Номенклатура = втЗапасыЗН.Номенклатура)
		                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.RMS_РезервыПодЗаказНаряд.Остатки(
		                |				,
		                |				Номенклатура В
		                |					(ВЫБРАТЬ
		                |						Аналоги.Аналог
		                |					ИЗ
		                |						втАналогиВсе КАК Аналоги)) КАК RMS_РезервыПодЗаказНарядОстатки
		                |		ПО (втАналогиВсе.Аналог = RMS_РезервыПодЗаказНарядОстатки.Номенклатура)
		                |;
		                |
		                |////////////////////////////////////////////////////////////////////////////////
		                |ВЫБРАТЬ
		                |	втЗапасыЗН.Номенклатура КАК Номенклатура,
		                |	ВЫБОР
		                |		КОГДА втАналогиОстатки.Аналог ЕСТЬ NULL
		                |			ТОГДА втЗапасыЗН.Номенклатура
		                |		ИНАЧЕ втАналогиОстатки.Аналог
		                |	КОНЕЦ КАК Аналог,
		                |	ВЫБОР
		                |		КОГДА втАналогиОстатки.Аналог ЕСТЬ NULL
		                |			ТОГДА втЗапасыЗН.КоличествоОстаток
		                |		ИНАЧЕ втАналогиОстатки.КоличествоРасчетное
		                |	КОНЕЦ КАК КоличествоРасчетное,
		                |	втЗапасыЗН.Количество КАК КоличествоПоЗН,
		                |	втЗапасыЗН.КоличествоОстаток КАК КоличествоОстаток,
						//{[+] Инфостарт А.Васильев 27.12.2021 #6069
						|	ВЫБОР
						|		КОГДА втАналогиОстатки.Аналог ЕСТЬ NULL
						|			ТОГДА 1
						|		ИНАЧЕ втАналогиОстатки.ОстатокПокрываетПотребность
						|	КОНЕЦ КАК ОстатокПокрываетПотребность
						//} Инфостарт А.Васильев 27.12.2021
		                |ИЗ
		                |	втЗапасыЗН КАК втЗапасыЗН
		                |		ЛЕВОЕ СОЕДИНЕНИЕ втАналогиОстатки КАК втАналогиОстатки
		                |		ПО втЗапасыЗН.Номенклатура = втАналогиОстатки.Номенклатура
		                |
		                |УПОРЯДОЧИТЬ ПО
		                |	Номенклатура,
						//{[+] Инфостарт А.Васильев 27.12.2021 #6069
						|	ОстатокПокрываетПотребность,
						//} Инфостарт А.Васильев 27.12.2021
		                |	КоличествоРасчетное
		                |ИТОГИ
		                |	СУММА(КоличествоРасчетное),
		                |	МИНИМУМ(КоличествоПоЗН),
		                |	МИНИМУМ(КоличествоОстаток),
						//{[+] Инфостарт А.Васильев 27.12.2021 #6069
						|	МИНИМУМ(ОстатокПокрываетПотребность)
						//} Инфостарт А.Васильев 27.12.2021
		                |ПО
		                |	Номенклатура,
		                |	Аналог";
		
	   	Запрос.УстановитьПараметр("Ссылка",Ссылка);	
		Запрос.УстановитьПараметр("СтруктурнаяЕдиница",Ссылка.RMS_СкладХраненияЗапасов);
		
		РезультатЗапроса = Запрос.Выполнить();
		ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам,"Номенклатура");
		Пока ВыборкаНоменклатура.Следующий() Цикл
			Осталось =  ВыборкаНоменклатура.КоличествоПоЗН;
			ВыборкаАналог =  ВыборкаНоменклатура.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам,"Аналог");
			Пока ВыборкаАналог.Следующий() Цикл
				Если Осталось > 0 Тогда
					Если Осталось >= ВыборкаАналог.КоличествоРасчетное тогда
						НовСтр = табАналоги.Добавить();
						НовСтр.Номенклатура = ВыборкаНоменклатура.Номенклатура;
						НовСтр.Аналог = ВыборкаАналог.Аналог;
						НовСтр.Количество =  ВыборкаАналог.КоличествоРасчетное;
						Осталось = Осталось - ВыборкаАналог.КоличествоРасчетное;
					Иначе 
						НовСтр = табАналоги.Добавить();
						НовСтр.Номенклатура = ВыборкаНоменклатура.Номенклатура;
						НовСтр.Аналог = ВыборкаАналог.Аналог;
						НовСтр.Количество = Осталось;
						Осталось = 0;
					КонецЕсли;
				Иначе
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если Осталось > 0 Тогда
				НовСтр = табАналоги.Добавить();
				НовСтр.Номенклатура = ВыборкаНоменклатура.Номенклатура;
				НовСтр.Аналог = ВыборкаНоменклатура.Номенклатура;
				Если ВыборкаНоменклатура.КоличествоОстаток >= Осталось Тогда
					НовСтр.Количество =  Осталось;
					Осталось = 0;
				Иначе
					НовСтр.Количество =  ВыборкаНоменклатура.КоличествоОстаток;
					Осталось = Осталось - ВыборкаНоменклатура.КоличествоОстаток;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла; 
		
		Запрос = Новый Запрос; 
		
		Запрос.Текст = "ВЫБРАТЬ
		|	Аналоги.Аналог КАК Аналог,
		|	Аналоги.Номенклатура КАК Номенклатура,
		|	Аналоги.Количество КАК Количество
		|ПОМЕСТИТЬ втАналоги
		|ИЗ
		|	&ТА КАК Аналоги
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втАналоги.Аналог КАК Номенклатура,
		|	втАналоги.Номенклатура КАК Оригинал,
		|	ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка) КАК Характеристика,
		|	НоменклатураСправочник.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
		|	втАналоги.Количество КАК Количество	
		|ИЗ
		|	втАналоги КАК втАналоги
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатураСправочник
		|		ПО (втАналоги.Аналог = НоменклатураСправочник.Ссылка)";	
				
		// --- Инфостарт Васильев А.Э. 01.12.2021
		Запрос.УстановитьПараметр("ТА",табАналоги);	

		тЗапасов = Запрос.Выполнить().Выгрузить();

	Иначе
		Запрос = Новый Запрос;
		Запрос.Текст = 	"ВЫБРАТЬ
		               	|	асЗаказНарядЗапасы.Номенклатура КАК Номенклатура,
						// +++ Инфостарт Васильев А.Э. 01.12.2021
						|	асЗаказНарядЗапасы.Номенклатура КАК Оригинал,
						// --- Инфостарт Васильев А.Э. 01.12.2021
		               	|	асЗаказНарядЗапасы.Характеристика КАК Характеристика,
		               	|	асЗаказНарядЗапасы.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
		               	|	асЗаказНарядЗапасы.Количество КАК Количество
		               	|ИЗ
		               	|	Документ.асЗаказНаряд.Запасы КАК асЗаказНарядЗапасы
		               	|ГДЕ
		               	|	асЗаказНарядЗапасы.Ссылка = &Ссылка
		               	|
		               	|ОБЪЕДИНИТЬ ВСЕ
		               	|
		               	|ВЫБРАТЬ
		               	|	асЗаказНарядМатериалыЗаказчика.Номенклатура,
						// +++ Инфостарт Васильев А.Э. 01.12.2021
						|	асЗаказНарядМатериалыЗаказчика.Номенклатура,
						// --- Инфостарт Васильев А.Э. 01.12.2021
		               	|	асЗаказНарядМатериалыЗаказчика.Характеристика,
		               	|	асЗаказНарядМатериалыЗаказчика.ЕдиницаИзмерения,
		               	|	асЗаказНарядМатериалыЗаказчика.Количество
		               	|ИЗ
		               	|	Документ.асЗаказНаряд.МатериалыЗаказчика КАК асЗаказНарядМатериалыЗаказчика
		               	|ГДЕ
		               	|	асЗаказНарядМатериалыЗаказчика.Ссылка = &Ссылка";
		Запрос.УстановитьПараметр("Ссылка",Ссылка);	
		тЗапасов = Запрос.Выполнить().Выгрузить();
		
	КонецЕсли;
			
	Возврат тЗапасов;		
			
	
КонецФункции // --- Инфостарт Васильев А.Э. 08.11.2021
