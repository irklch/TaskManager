# MVVM Documentation

## ViewModels

### 1. ContentViewViewModel
**Файл:** `TaskManager/ContentView/ContentViewViewModel.swift`

**Функциональность:**
- Управление состоянием главного экрана
- Обработка жестов скролла для скрытия/показа таб-бара
- Управление данными задач и папок через Core Data
- Создание элементов таб-бара
- Управление показом экрана добавления задач

**Ключевые свойства:**
- `@Published var selectedIndex: Int` - выбранный индекс таба
- `@Published var isTabBarVisible: Bool` - видимость таб-бара
- `@Published var showAddTask: Bool` - показ экрана добавления задач
- `@Published var tasks: [Task]` - список задач
- `@Published var folders: [TaskFolder]` - список папок

### 2. TaskScreenViewModel
**Файл:** `TaskManager/TaskScreenView/TaskScreenViewModel.swift`

**Функциональность:**
- Управление состоянием экрана задач
- Фильтрация задач по выбранной папке
- Подсчет выполненных и выполняющихся задач
- Форматирование дат
- Создание ViewModels для дочерних компонентов

**Ключевые методы:**
- `getFilteredTasks()` - получение отфильтрованных задач
- `calculateTaskCounts()` - подсчет количества задач
- `formatDate(_:)` - форматирование дат
- `createTaskResultViewModel(for:)` - создание ViewModel для результата задач
- `createTaskItemViewModel(for:)` - создание ViewModel для элемента задачи

### 3. AddTaskViewModel
**Файл:** `TaskManager/TaskScreenView/AddTaskView/AddTaskViewModel.swift`

**Функциональность:**
- Управление состоянием экрана добавления задач
- Валидация формы
- Сохранение задач в Core Data
- Управление изображениями
- Очистка формы

**Ключевые свойства:**
- `@Published var taskTitle: String` - заголовок задачи
- `@Published var taskDescription: String` - описание задачи
- `@Published var selectedImage: UIImage?` - выбранное изображение
- `@Published var showingImagePicker: Bool` - показ пикера изображений

**Вычисляемые свойства:**
- `isSaveButtonEnabled: Bool` - активность кнопки сохранения
- `saveButtonOpacity: Double` - прозрачность кнопки сохранения

### 4. CalendarViewModel
**Файл:** `TaskManager/CalendarView/CalendarViewModel.swift`

**Функциональность:**
- Управление состоянием календарного экрана
- Навигация по датам
- Генерация mock данных для демонстрации
- Создание ViewModels для строк задач

**Ключевые методы:**
- `navigateToPreviousDate()` - переход к предыдущей дате
- `navigateToNextDate()` - переход к следующей дате
- `selectDate(at:)` - выбор конкретной даты
- `getSelectedDateName()` - получение названия выбранной даты
- `getTasksCount()` - получение количества задач

## Использование Combine

Все ViewModels используют Combine framework для:
- Реактивного обновления UI при изменении данных
- Обработки событий Core Data
- Управления жизненным циклом подписок через `cancellables`
