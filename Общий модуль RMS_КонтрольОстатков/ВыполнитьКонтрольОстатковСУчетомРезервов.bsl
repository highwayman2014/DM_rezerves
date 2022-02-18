// BSLLS-off
Процедура ВыполнитьКонтрольОстатковСУчетомРезервов(ДокументСсылка, ДополнительныеСвойства, Отказ, УдалениеПроведения = Ложь) Экспорт
	
	Если Не УправлениеНебольшойФирмойСервер.ВыполнитьКонтрольОстатков() Тогда
		Возврат;
	КонецЕсли;

	СтруктураВременныеТаблицы = ДополнительныеСвойства.ДляПроведения.СтруктураВременныеТаблицы;
	
	// Если временные таблицы "ДвиженияЗапасыНаСкладахИзменение".
	
	Если СтруктураВременныеТаблицы.ДвиженияЗапасыНаСкладахИзменение Тогда
				
		Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	ДвиженияЗапасыНаСкладахИзменение.НомерСтроки КАК НомерСтроки,
		|	ДвиженияЗапасыНаСкладахИзменение.Организация КАК ОрганизацияПредставление,
		|	ДвиженияЗапасыНаСкладахИзменение.СтруктурнаяЕдиница КАК СтруктурнаяЕдиницаПредставление,
		|	ДвиженияЗапасыНаСкладахИзменение.Номенклатура КАК НоменклатураПредставление,
		|	ДвиженияЗапасыНаСкладахИзменение.Характеристика КАК ХарактеристикаПредставление,
		|	ЗапасыНаСкладахОстатки.СтруктурнаяЕдиница.ТипСтруктурнойЕдиницы КАК ТипСтруктурнойЕдиницы,
		|	ЗапасыНаСкладахОстатки.Номенклатура.ЕдиницаИзмерения КАК ЕдиницаИзмеренияПредставление,
		|	ЕСТЬNULL(ДвиженияЗапасыНаСкладахИзменение.КоличествоИзменение, 0) + ЕСТЬNULL(ЗапасыНаСкладахОстатки.КоличествоОстаток, 0) КАК ОстатокЗапасыНаСкладах,
		|	ЕСТЬNULL(ЗапасыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстатокЗапасыНаСкладах,
		|	ЕСТЬNULL(ЗапасыНаСкладахОстатки.КоличествоОстатокРезервы, 0) КАК КоличествоОстатокРезервы
		|ИЗ
		|	ДвиженияЗапасыНаСкладахИзменение КАК ДвиженияЗапасыНаСкладахИзменение
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			ЕСТЬNULL(Запасы.Организация, Резервы.Организация) КАК Организация,
		|			ЕСТЬNULL(Запасы.СтруктурнаяЕдиница, Резервы.СтруктурнаяЕдиница) КАК СтруктурнаяЕдиница,
		|			ЕСТЬNULL(Запасы.Номенклатура, Резервы.Номенклатура) КАК Номенклатура,
		|			ЕСТЬNULL(Запасы.Характеристика, Резервы.Характеристика) КАК Характеристика,
		|			СУММА(ЕСТЬNULL(Запасы.КоличествоОстаток, 0)) - СУММА(ВЫБОР
		|					КОГДА ЕСТЬNULL(Резервы.КоличествоОстаток, 0) >= 0
		|						ТОГДА ЕСТЬNULL(Резервы.КоличествоОстаток, 0)
		|					ИНАЧЕ 0
		|				КОНЕЦ) КАК КоличествоОстаток,
		|			СУММА(ЕСТЬNULL(Резервы.КоличествоОстаток, 0)) КАК КоличествоОстатокРезервы
		|		ИЗ
		|			(ВЫБРАТЬ
		|				Запасы.Организация КАК Организация,
		|				Запасы.СтруктурнаяЕдиница КАК СтруктурнаяЕдиница,
		|				Запасы.Номенклатура КАК Номенклатура,
		|				Запасы.Характеристика КАК Характеристика,
		|				СУММА(Запасы.КоличествоОстаток) КАК КоличествоОстаток
		|			ИЗ
		|				РегистрНакопления.ЗапасыНаСкладах.Остатки(
		|						&МоментКонтроля,
		|						(Организация, СтруктурнаяЕдиница, Номенклатура, Характеристика) В
		|							(ВЫБРАТЬ
		|								ДвиженияЗапасыНаСкладахИзменение.Организация КАК Организация,
		|								ДвиженияЗапасыНаСкладахИзменение.СтруктурнаяЕдиница КАК СтруктурнаяЕдиница,
		|								ДвиженияЗапасыНаСкладахИзменение.Номенклатура КАК Номенклатура,
		|								ДвиженияЗапасыНаСкладахИзменение.Характеристика КАК Характеристика
		|							ИЗ
		|								ДвиженияЗапасыНаСкладахИзменение КАК ДвиженияЗапасыНаСкладахИзменение)) КАК Запасы
		|			
		|			СГРУППИРОВАТЬ ПО
		|				Запасы.Организация,
		|				Запасы.СтруктурнаяЕдиница,
		|				Запасы.Номенклатура,
		|				Запасы.Характеристика) КАК Запасы
		|				ПОЛНОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|					Резервы.Организация КАК Организация,
		|					Резервы.СтруктурнаяЕдиница КАК СтруктурнаяЕдиница,
		|					Резервы.Номенклатура КАК Номенклатура,
		|					Резервы.Характеристика КАК Характеристика,
		|					СУММА(ВЫБОР
		|							КОГДА Резервы.асЗаказНаряд = &ЗаказНаряд
		|								ТОГДА 0
		|							ИНАЧЕ Резервы.КоличествоОстаток
		|						КОНЕЦ) КАК КоличествоОстаток
		|				ИЗ
		|					РегистрНакопления.RMS_РезервыПодЗаказНаряд.Остатки(
		|							&МоментКонтроля,
		|							(Организация, СтруктурнаяЕдиница, Номенклатура, Характеристика) В
		|								(ВЫБРАТЬ
		|									ДвиженияЗапасыНаСкладахИзменение.Организация КАК Организация,
		|									ДвиженияЗапасыНаСкладахИзменение.СтруктурнаяЕдиница КАК СтруктурнаяЕдиница,
		|									ДвиженияЗапасыНаСкладахИзменение.Номенклатура КАК Номенклатура,
		|									ДвиженияЗапасыНаСкладахИзменение.Характеристика КАК Характеристика
		|								ИЗ
		|									ДвиженияЗапасыНаСкладахИзменение КАК ДвиженияЗапасыНаСкладахИзменение)) КАК Резервы
		|				
		|				СГРУППИРОВАТЬ ПО
		|					Резервы.Организация,
		|					Резервы.СтруктурнаяЕдиница,
		|					Резервы.Номенклатура,
		|					Резервы.Характеристика) КАК Резервы
		|				ПО Запасы.Организация = Резервы.Организация
		|					И Запасы.СтруктурнаяЕдиница = Резервы.СтруктурнаяЕдиница
		|					И Запасы.Номенклатура = Резервы.Номенклатура
		|					И Запасы.Характеристика = Резервы.Характеристика
		|		
		|		СГРУППИРОВАТЬ ПО
		|			ЕСТЬNULL(Запасы.Организация, Резервы.Организация),
		|			ЕСТЬNULL(Запасы.СтруктурнаяЕдиница, Резервы.СтруктурнаяЕдиница),
		|			ЕСТЬNULL(Запасы.Номенклатура, Резервы.Номенклатура),
		|			ЕСТЬNULL(Запасы.Характеристика, Резервы.Характеристика)) КАК ЗапасыНаСкладахОстатки
		|		ПО ДвиженияЗапасыНаСкладахИзменение.Организация = ЗапасыНаСкладахОстатки.Организация
		|			И ДвиженияЗапасыНаСкладахИзменение.СтруктурнаяЕдиница = ЗапасыНаСкладахОстатки.СтруктурнаяЕдиница
		|			И ДвиженияЗапасыНаСкладахИзменение.Номенклатура = ЗапасыНаСкладахОстатки.Номенклатура
		|			И ДвиженияЗапасыНаСкладахИзменение.Характеристика = ЗапасыНаСкладахОстатки.Характеристика
		|			И (ЕСТЬNULL(ЗапасыНаСкладахОстатки.КоличествоОстаток, 0) < 0)
		|
		|УПОРЯДОЧИТЬ ПО
		|	НомерСтроки");
		

		Запрос.МенеджерВременныхТаблиц = СтруктураВременныеТаблицы.МенеджерВременныхТаблиц;
		Запрос.УстановитьПараметр("МоментКонтроля", ДополнительныеСвойства.ДляПроведения.МоментКонтроля);
		
		ЗаказНаряд = Документы.асЗаказНаряд.ПустаяСсылка();
		Если ТипЗнч(ДокументСсылка) = Тип("ДокументСсылка.ПеремещениеЗапасов") Тогда 
			Если ТипЗнч(ДокументСсылка.ДокументОснование) = Тип("ДокументСсылка.асЗаказНаряд") Тогда
				ЗаказНаряд = ДокументСсылка.ДокументОснование;
			КонецЕсли;		
		КонецЕсли;
		Запрос.УстановитьПараметр("ЗаказНаряд", ЗаказНаряд);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Если НЕ РезультатЗапроса.Пустой() Тогда
			
			ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
			
			ВремОтказ = Ложь;
			
			// Отрицательный остаток запасов на складе с учетом резервов.
			ВыборкаИзРезультатаЗапроса = РезультатЗапроса.Выбрать();
			СообщитьОбОшибкахПроведенияПоРегиструЗапасыНаСкладах(
				ДокументОбъект, 
				ВыборкаИзРезультатаЗапроса, 
				ВремОтказ
			);
			
		КонецЕсли;
				
	КонецЕсли;
	
КонецПроцедуры // ВыполнитьКонтрольОтрицательныхОстатков()
