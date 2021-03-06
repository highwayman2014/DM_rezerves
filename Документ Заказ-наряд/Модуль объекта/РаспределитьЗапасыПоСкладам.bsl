// +++ Инфостарт #2666 04.08.2021
Процедура РаспределитьЗапасыПоСкладам(ДокументОбъект, МассивДокументов)
	
	// Получение данных
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтруктурныеЕдиницы.Ссылка КАК Склад
		|ПОМЕСТИТЬ ВТСклады
		|ИЗ
		|	Справочник.СтруктурныеЕдиницы КАК СтруктурныеЕдиницы
		|ГДЕ
		|	СтруктурныеЕдиницы.дмРаспределятьРезервЗапчастейНаСкладе = ИСТИНА
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаДокумента.Номенклатура КАК Номенклатура,
		|	ТаблицаДокумента.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ВТТаблицаДокумента
		|ИЗ
		|	&ТаблицаДокумента КАК ТаблицаДокумента
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЗапасыНаСкладахОстатки.Организация КАК Организация,
		|	ЗапасыНаСкладахОстатки.Номенклатура КАК Номенклатура,
		|	ЗапасыНаСкладахОстатки.Характеристика КАК Характеристика,
		|	ЗапасыНаСкладахОстатки.СтруктурнаяЕдиница КАК СтруктурнаяЕдиница,
		|	ЗапасыНаСкладахОстатки.КоличествоОстаток КАК КоличествоОстаток
		// +++ Инфостарт 09.08.2021
		|ПОМЕСТИТЬ ВТОстаткиСрезервом
		// --- Инфостарт 09.08.2021
		|ИЗ
		|	РегистрНакопления.ЗапасыНаСкладах.Остатки(
		|			,
		|			СтруктурнаяЕдиница В
		|					(ВЫБРАТЬ
		|						ВТСклады.Склад
		|					ИЗ
		|						ВТСклады КАК ВТСклады)
		|				И Организация = &Организация
		|				И (Номенклатура, Характеристика) В
		|					(ВЫБРАТЬ
		|						ВТТаблицаДокумента.Номенклатура КАК Номенклатура,
		|						ВТТаблицаДокумента.Характеристика КАК Характеристика
		|					ИЗ
		|						ВТТаблицаДокумента КАК ВТТаблицаДокумента)) КАК ЗапасыНаСкладахОстатки
		// +++ Инфостарт 09.08.2021
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	RMS_РезервыПодЗаказНарядОстатки.Организация КАК Организация,
		|	RMS_РезервыПодЗаказНарядОстатки.Номенклатура КАК Номенклатура,
		|	RMS_РезервыПодЗаказНарядОстатки.Характеристика КАК Характеристика,
		|	RMS_РезервыПодЗаказНарядОстатки.СтруктурнаяЕдиница КАК СтруктурнаяЕдиница,
		|	-1 * RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.RMS_РезервыПодЗаказНаряд.Остатки(
		|			,
		|			СтруктурнаяЕдиница В
		|					(ВЫБРАТЬ
		|						ВТСклады.Склад
		|					ИЗ
		|						ВТСклады КАК ВТСклады)
		|				И Организация = &Организация
		|				И (Номенклатура, Характеристика) В
		|					(ВЫБРАТЬ
		|						ВТТаблицаДокумента.Номенклатура КАК Номенклатура,
		|						ВТТаблицаДокумента.Характеристика КАК Характеристика
		|					ИЗ
		|						ВТТаблицаДокумента КАК ВТТаблицаДокумента)) КАК RMS_РезервыПодЗаказНарядОстатки
		|ГДЕ
		|	RMS_РезервыПодЗаказНарядОстатки.КоличествоОстаток > 0
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТОстаткиСрезервом.Организация КАК Организация,
		|	ВТОстаткиСрезервом.Номенклатура КАК Номенклатура,
		|	ВТОстаткиСрезервом.Характеристика КАК Характеристика,
		|	ВТОстаткиСрезервом.СтруктурнаяЕдиница КАК СтруктурнаяЕдиница,
		|	СУММА(ВТОстаткиСрезервом.КоличествоОстаток) КАК КоличествоОстаток
		|ИЗ
		|	ВТОстаткиСрезервом КАК ВТОстаткиСрезервом
		|
		|СГРУППИРОВАТЬ ПО
		|	ВТОстаткиСрезервом.Организация,
		|	ВТОстаткиСрезервом.Номенклатура,
		|	ВТОстаткиСрезервом.Характеристика,
		|	ВТОстаткиСрезервом.СтруктурнаяЕдиница
		|
		|УПОРЯДОЧИТЬ ПО
		|	Организация,
		|	Номенклатура,
		|	Характеристика,
		|	СтруктурнаяЕдиница,
		|	КоличествоОстаток УБЫВ";
		// --- Инфостарт 09.08.2021
	
	Запрос.УстановитьПараметр("Организация",      Организация);
	Запрос.УстановитьПараметр("ТаблицаДокумента", ДокументОбъект.Запасы.Выгрузить(,"Номенклатура,Характеристика"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ТаблицаОстатков = РезультатЗапроса.Выгрузить();
	
	ДокументИзменен = Ложь;
	НовыйСклад = Справочники.СтруктурныеЕдиницы.ПустаяСсылка();
	
	Для Каждого СтрокаЗапаса Из ДокументОбъект.Запасы Цикл
		
		ОсталосьОтгрузить = СтрокаЗапаса.Количество;
		
		// Проверка остатка на текущем складе
		ОстатокНаТекущемСкладе = 0;
		
		ПараметрыОтбораОстатков = Новый Структура("Организация, Номенклатура, Характеристика, СтруктурнаяЕдиница",
			Организация, СтрокаЗапаса.Номенклатура, СтрокаЗапаса.Характеристика, ДокументОбъект.дмСкладХраненияЗапасов);
		
		НайденныеСтрокиОстатков = ТаблицаОстатков.НайтиСтроки(ПараметрыОтбораОстатков);
		
		Если НайденныеСтрокиОстатков.Количество() > 0 Тогда
			ОстатокНаТекущемСкладе = НайденныеСтрокиОстатков[0].КоличествоОстаток;
		КонецЕсли;
		
		Если ОстатокНаТекущемСкладе >= ОсталосьОтгрузить Тогда
			
			НайденныеСтрокиОстатков[0].КоличествоОстаток = НайденныеСтрокиОстатков[0].КоличествоОстаток - ОсталосьОтгрузить;
			ТаблицаОстатков.Сортировать("Организация, Номенклатура, Характеристика, КоличествоОстаток Убыв");
			
			НовыйСклад = ДокументОбъект.дмСкладХраненияЗапасов;
			
			Продолжить;
			
		КонецЕсли;
		
		// Проверка наличия всего товара на другом складе
		ПараметрыОтбораОстатков = Новый Структура("Организация, Номенклатура, Характеристика",
			Организация, СтрокаЗапаса.Номенклатура, СтрокаЗапаса.Характеристика);
		
		НайденныеСтрокиОстатков = ТаблицаОстатков.НайтиСтроки(ПараметрыОтбораОстатков);
		
		// Проверка наличия всего товара на нескольких сторонних складах
		Для Каждого НайденнаяСтрокаОстатков Из НайденныеСтрокиОстатков Цикл
			
			// Перевод всего оставшегося товара на сторонний склад
			Если НайденнаяСтрокаОстатков.КоличествоОстаток >= ОсталосьОтгрузить И НайденнаяСтрокаОстатков.КоличествоОстаток > 0
					И ОсталосьОтгрузить > 0 Тогда
				
				// Если в документе уже происходило изменение склада, то перенесем строку в новый документ
				Если ДокументИзменен И ЗначениеЗаполнено(НовыйСклад) И НовыйСклад <> НайденнаяСтрокаОстатков.СтруктурнаяЕдиница Тогда
					
					// Создание нового документа
					НовыйДокументОбъект = ДокументОбъект.Скопировать();
					НовыйДокументОбъект.Дата                   = ДокументОбъект.Дата;
					НовыйДокументОбъект.дмСкладХраненияЗапасов = НайденнаяСтрокаОстатков.СтруктурнаяЕдиница;
					НовыйДокументОбъект.Запасы.Очистить();
					
					НоваяСтрока = НовыйДокументОбъект.Запасы.Добавить();
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаЗапаса);
					НоваяСтрока.СтавкаНДС             = НоваяСтрока.Номенклатура.СтавкаНДС;
					НоваяСтрока.дмРезервировать       = Истина;
					НоваяСтрока.Количество            = ОсталосьОтгрузить;
					НоваяСтрока.дмКоличествоОтгружено = 0;
					НоваяСтрока.Сумма                 = НоваяСтрока.Цена * НоваяСтрока.Количество;
					НоваяСтрока.дмАвтомобиль          = СтрокаЗапаса.дмАвтомобиль;
					НоваяСтрока.ДатаПоступления       = ДатаНачала;
					
					ПараметрыРасчета = Новый Структура("СуммаВключаетНДС", НовыйДокументОбъект.СуммаВключаетНДС);
					УправлениеНебольшойФирмойКлиентСервер.РассчитатьСуммуНДСИВсего(НоваяСтрока, ПараметрыРасчета);
					
					НовыйДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
					
					МассивДокументов.Добавить(НовыйДокументОбъект.Ссылка);
					
					// Редактирование старого документа
					СтрокаЗапаса.Количество = СтрокаЗапаса.Количество - ОсталосьОтгрузить;
					СтрокаЗапаса.Сумма      = СтрокаЗапаса.Цена       * СтрокаЗапаса.Количество;
					
					ПараметрыРасчета = Новый Структура("СуммаВключаетНДС", ДокументОбъект.СуммаВключаетНДС);
					УправлениеНебольшойФирмойКлиентСервер.РассчитатьСуммуНДСИВсего(СтрокаЗапаса, ПараметрыРасчета);
					
				// Если в документе это первое изменение склада
				Иначе
					
					НовыйСклад = НайденнаяСтрокаОстатков.СтруктурнаяЕдиница;
					ДокументОбъект.дмСкладХраненияЗапасов = НайденнаяСтрокаОстатков.СтруктурнаяЕдиница;
					
				КонецЕсли;
				
				ДокументИзменен = Истина;
				
				НайденнаяСтрокаОстатков.КоличествоОстаток = НайденнаяСтрокаОстатков.КоличествоОстаток - ОсталосьОтгрузить;
				ОсталосьОтгрузить = 0;
				
			// Перевод части оставшегося товара на сторонний склад
			ИначеЕсли НайденнаяСтрокаОстатков.КоличествоОстаток > 0 И ОсталосьОтгрузить > 0 Тогда
				
				// Создание нового документа
				НовыйДокументОбъект = ДокументОбъект.Скопировать();
				НовыйДокументОбъект.Дата                   = ДокументОбъект.Дата;
				НовыйДокументОбъект.дмСкладХраненияЗапасов = НайденнаяСтрокаОстатков.СтруктурнаяЕдиница;
				НовыйДокументОбъект.Запасы.Очистить();
				
				НоваяСтрока = НовыйДокументОбъект.Запасы.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаЗапаса);
				НоваяСтрока.СтавкаНДС             = НоваяСтрока.Номенклатура.СтавкаНДС;
				НоваяСтрока.дмРезервировать       = Истина;
				НоваяСтрока.Количество            = НайденнаяСтрокаОстатков.КоличествоОстаток;
				НоваяСтрока.дмКоличествоОтгружено = 0;
				НоваяСтрока.Сумма                 = НоваяСтрока.Цена * НоваяСтрока.Количество;
				НоваяСтрока.дмАвтомобиль          = СтрокаЗапаса.дмАвтомобиль;
				НоваяСтрока.ДатаПоступления       = ДатаНачала;
				
				ПараметрыРасчета = Новый Структура("СуммаВключаетНДС", НовыйДокументОбъект.СуммаВключаетНДС);
				УправлениеНебольшойФирмойКлиентСервер.РассчитатьСуммуНДСИВсего(НоваяСтрока, ПараметрыРасчета);
				
				НовыйДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
				
				МассивДокументов.Добавить(НовыйДокументОбъект.Ссылка);
				
				// Редактирование старого документа
				СтрокаЗапаса.Количество = СтрокаЗапаса.Количество - НайденнаяСтрокаОстатков.КоличествоОстаток;
				СтрокаЗапаса.Сумма      = СтрокаЗапаса.Цена       * СтрокаЗапаса.Количество;
				
				ПараметрыРасчета = Новый Структура("СуммаВключаетНДС", ДокументОбъект.СуммаВключаетНДС);
				УправлениеНебольшойФирмойКлиентСервер.РассчитатьСуммуНДСИВсего(СтрокаЗапаса, ПараметрыРасчета);
				
				ДокументИзменен = Истина;
				
				ОсталосьОтгрузить = ОсталосьОтгрузить - НайденнаяСтрокаОстатков.КоличествоОстаток;
				НайденнаяСтрокаОстатков.КоличествоОстаток = 0;
				
			КонецЕсли;
			
		КонецЦикла;
		
		ТаблицаОстатков.Сортировать("Организация, Номенклатура, Характеристика, КоличествоОстаток Убыв");
		
	КонецЦикла;
	
	// Удаление строк с нулевым количеством
	МассивУдаляемыхСтрок = Новый Массив;
	
	Для Каждого СтрокаЗапаса Из ДокументОбъект.Запасы Цикл
		Если СтрокаЗапаса.Количество = 0 Тогда
			МассивУдаляемыхСтрок.Добавить(СтрокаЗапаса);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого УдаляемаяСтрока Из МассивУдаляемыхСтрок Цикл
		ДокументОбъект.Запасы.Удалить(УдаляемаяСтрока);
	КонецЦикла;
	
	ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
	
КонецПроцедуры

