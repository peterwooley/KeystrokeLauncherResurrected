local L = LibStub("AceLocale-3.0"):NewLocale("KeystrokeLauncherResurrected", "ruRU", false)

if L then
-- Translator ZamestoTV
--[=====[ OPTIONS --]=====]
-- share
L["config_print"] = "печать"
L["config_keybinding"] = "Назначение клавиш"
L["OPEN"] = "Открыть"
L["CLEAR"] = "Очистить"
L["PRINT"] = "Печать"

-- individual
L["config_hide_name"] = "Скрыть"
L["config_hide_desc"] = "Скрыть окно настроек"
L["config_show_name"] = "Показать"
L["config_show_desc"] = "Показать окно настроек"
L["config_group_keybindungs_desc"] = "Настроить свои клавиши"
L["config_modifiers"] = "Модификаторы"
L["config_modifiers_alt"] = "Alt"
L["config_modifiers_ctrl"] = "Ctrl"
L["config_modifiers_shift"] = "Shift"
L["config_reset_name"] = "Сбросить всё"
L["config_reset_desc"] = "Сброс до заводских настроек"
L["config_reset_confirmText"] = "Это сбросит базу данных Keystroke Launcher до значений по умолчанию - продолжить?"

-- search table
L["config_search_table_name"] = "Поисковый индекс"
L["config_search_table_header_one"] = "Главный поисковый индекс"
L["config_search_table_rebuild"] = "Обновить индекс"
L["config_search_table_header_two"] = "Настройка индексации"
L["config_search_table_desc"] = "Не забудьте нажать кнопку 'Обновить', если вы включили или выключили какой-либо модуль.\n\nПримечание: включение модуля аддонов будет приводить к небольшому зависанию при каждом обновлении базы данных, особенно если у вас установлено большое количество модификаций (по умолчанию: один раз при входе в игру)."
L["config_search_table_index"] = "Выберите, чтобы включить"

L["config_search_freq_table_name"] = "Индекс частоты поиска"
L["config_search_freq_table_desc"] = "Индекс частоты поиска сохраняет информацию о том, как часто вы что-то запускали."
L["config_search_freq_table_cleared"] = "Индекс частоты поиска очищен"
L['CONFIG_SEARCH_TABLE_CUSTOM_HEADER'] = "Пользовательские данные поиска"

L['CONFIG_INDEX_TYPES_ADDON'] = 'Аддоны'
L['CONFIG_INDEX_TYPES_MACRO'] = 'Макросы'
L['CONFIG_INDEX_TYPES_SPELL'] = 'Заклинания'
L['CONFIG_INDEX_TYPES_CMD'] = 'Слэш-команды'
L['CONFIG_INDEX_TYPES_ITEM'] = 'Предметы'
L['CONFIG_INDEX_TYPES_MOUNT'] = 'Средства передвижения'
L['CONFIG_INDEX_TYPES_EQUIP_SET'] = 'Комплекты экипировки'
L['CONFIG_INDEX_TYPES_BLIZZ_FRAME'] = 'Фреймы Blizzard'
L['CONFIG_INDEX_TYPES_CVAR'] = 'Параметры CVAR'
L['CONFIG_INDEX_TYPES_TOY'] = 'Игрушки'

-- look n feel
L['CONFIG_LOOK_N_FEEL_HEADER'] = 'Отображение элементов'
L['CONFIG_LOOK_N_FEEL_TOOLTIP_NAME'] = 'Подсказки'
L['CONFIG_LOOK_N_FEEL_TOOLTIP_DESC'] = 'Включает / выключает всплывающие подсказки'
L['CONFIG_LOOK_N_FEEL_MARKER_NAME'] = "Маркер типа"
L['CONFIG_LOOK_N_FEEL_MARKER_DESC'] = "Показывать/скрывать маркер типа поиска (цветные точки)."
L['CONFIG_LOOK_N_FEEL_CHECKBOXES_NAME'] = "Флажки типов"
L['CONFIG_LOOK_N_FEEL_CHECKBOXES_DESC'] = "Показывать/скрывать флажки фильтрации по типам поиска."
L['CONFIG_LOOK_N_FEEL_HEADER_EXPERIMENTAL'] = "Экспериментальные настройки"
L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_NAME'] = "Быстрый фильтр типов поиска"
L['CONFIG_LOOK_N_FEEL_QUICK_FILTER_DESC'] = [[Если включено, цифры в строке поиска будут интерпретироваться как типы поиска. ID категории поиска - это цифра в квадратных скобках.

Пример: если вы введете `r4`, инструмент отфильтрует список результатов по категории поиска с ID `4` и строке `r`.

Примечание 1: работает только при включенных Флажках типов.
Примечание 2: поскольку цифры становятся специальными управляющими символами, вы больше не сможете использовать их для обычной фильтрации текста.]]
L['CONFIG_LOOK_N_FEEL_EDIT_MODE_NAME'] = 'Режим редактирования'
L['CONFIG_LOOK_N_FEEL_EDIT_MODE_DESC'] = 'Показывать/скрывать флажок, который включает и выключает режим редактирования.'
L['CONFIG_LOOK_N_FEEL_TOP_MACROS_NAME'] = 'Запись популярных макросов'
L['CONFIG_LOOK_N_FEEL_TOP_MACROS_DESC'] = [[Если включено, 5 наиболее часто используемых элементов будут сохранены в макросы конкретного персонажа с именами `kl-top-n`, где n - от 1 до 5. Макросы будут созданы, если они не существуют и есть свободное место для макросов.

Чтобы видеть более информативные подсказки к макросам, пожалуйста, установите аддон Custom Tooltips (https://www.curseforge.com/wow/addons/custom-tooltips).]]
L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_NAME'] = 'Кликабельные иконки предметов'
L['CONFIG_LOOK_N_FEEL_SHOW_ACTION_ICONS_DESC'] = 'Если включено, вы сможете активировать предмет, нажав на его иконку. Отключите, чтобы уменьшить размер иконок.'
L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_NAME'] = "Макс. элементов на странице"
L['CONFIG_LOOK_N_FEEL_MAX_ITEMS_DESC'] = "Управляет количеством строк в окне результатов. По умолчанию: 7."
L['CONFIG_LOOK_N_FEEL_SCALE_NAME'] = "Масштаб интерфейса"
L['CONFIG_LOOK_N_FEEL_SCALE_DESC'] = "Управляет масштабом окна Keystroke Launcher. По умолчанию: 1."
L['CONFIG_LOOK_N_FEEL_SIZE'] = "Настройки размера интерфейса"

--[=====[ CODE --]=====]
L["INDEX_HEADER"] = "Поисковый индекс обновлен."
L["INDEX_DISABLED"] = "  Выключено: "
L["INDEX_ENABLED"] = "  Включено: "
L['INDEX_FOOTER'] = function(X)
    return 'Нажмите ' .. X .. ', чтобы начать!';
end

--[=====[ TOOLTIPS --]=====]
L["DB_SEARCH_RELOAD_UI"] = "Перезагрузить интерфейс"
L["DB_SEARCH_LOGOUT"] = "Выйти из игры"
L["DB_SEARCH_KL_SHOW"] = "Показать интерфейс Keystroke Launcher"
L["DB_SEARCH_KL_FREQ_PRINT"] = "Вывести таблицу частоты поиска KL"
L["DB_SEARCH_DISMOUNT"] = "Слезть со средства передвижения"
L["DB_SEARCH_KL_SEARCH_REBUILD"] = "Обновить поисковый индекс"

-- search index
L['CALENDAR'] = "Календарь"
L['SUMMON_RANDOM_FAVORITE_MOUNT'] = "Призвать случайное любимое средство передвижения."
L['TOGGLE_SOUND'] = "Включить/выключить общий звук"

end
