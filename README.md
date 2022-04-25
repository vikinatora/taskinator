# Taskinator

This is an iOS Project developed during the iOS Development course in TU Sofia.

# Features
- Facebook authentication in combinations with MongoDB Realm for persistance
- Main view for managing tasks
- Each task has 3 states: Open, In Progress, Completed
- In order to change the status of the task:
1. Create the task
2. Hold the task for 2 seconds
3. Release and a menu will appear
- Settings view for adjusting application behavior (Singleton Pattern)
1. You can hide your name in the tasks screen
2. You can override the default status when creating a task
- Custom side menu with gestures
1. You can use pan gesture (slide to right)
2. You can press the menu button in the navigation bar


# Задължителни изисквания: 
* Прилагане на MVC или друг design pattern (VIPER, MVVM и други) 
* Използване на Interface Builder (Storyboard) 
* Използване на Swift 
* Правилна употреба на access controls 

# Избираеми изисквания: 
* Минимум 3 екрана, свързани един с друг
* Употреба на UINavigationController 
* Употреба на UITableView или UICollectionView(UITableView) 
* Употреба на поне една анимация 
* Употреба на custom protocol/delegation (protocol)
* Използване на persistance - Core Data (MongoDB Realm)
* Създаване на Custom View (Side menu)
* Създаване на поне един Extension 
* Използване на enum 
* Използване на struct 
* Използване на поне един gesture в логиката на приложението (Side menu - pan gesture)
* Извличане на данни от сървър (networking) 
* Custom / Convenience Init (convenience init)
* Употреба на Singleton pattern - Settings
