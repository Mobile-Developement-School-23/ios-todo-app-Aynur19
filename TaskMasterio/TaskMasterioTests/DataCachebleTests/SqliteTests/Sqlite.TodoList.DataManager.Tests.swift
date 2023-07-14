//
//  Sqlite.TodoList.DataManager.Tests.swift
//  TaskMasterioTests
//
//  Created by Aynur Nasybullin on 14.07.2023.
//

import XCTest
@testable import TaskMasterio

final class SqliteTodoListDataManagerTests: XCTestCase {
    var dataManager: DataManager!

    override func setUpWithError() throws {
        dataManager = DataManager(unitOfWork: SqliteUnitOfWork(context1: TodoListContext.shared))
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        dataManager = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests configurate()
    func tests_CreateDatabase_IsNew() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: СОЗДАНИЕ БАЗЫ ДАННЫХ И ТАБЛИЦ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList_", withDatetime: true)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        print("************************************************************************\n")
    }
    
    func tests_CreateDatabase_IsStored() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: СОЗДАНИЕ БАЗЫ ДАННЫХ И ТАБЛИЦ ЕДИНОЖДЫ")

        let filepath = TestsData.getFilepath(prefix: "TodoList", withDatetime: false, isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        print("************************************************************************\n")
    }
    
    // MARK: - Tests getAll()
    func tests_GetAll() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ЗАГРУЗКА ВСЕХ ЗАПИСЕЙ ИЗ ТАБЛИЦЫ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()

        let items = dataManager.getAll()
        print("Количество записей в таблице: \(items.count)")
        
        for item in items { print("  \(item)") }
        print("************************************************************************\n")
    }
    
    // MARK: - Tests get()
    func tests_GetById_IdNotFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ЗАГРУЗКА КОНКРЕТНОЙ ЗАПИСИ ИЗ ТАБЛИЦЫ КОГДА ИДЕНТИФИКАТОР НЕ НАЙДЕН")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()

        let items = dataManager.getAll()
        print("Количество записей в таблице: \(items.count)")
        
        let id = UUID().uuidString
        print("Идентификатор для получения записи: \(id)")
        
        let item = dataManager.get(by: id)
        XCTAssertNil(item)
        print("Результат получения конкретной записи: \(item)")
        print("************************************************************************\n")
    }
    
    func tests_GetById_IdFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ЗАГРУЗКА КОНКРЕТНОЙ ЗАПИСИ ИЗ ТАБЛИЦЫ КОГДА ИДЕНТИФИКАТОР НАЙДЕН")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()

        let items = dataManager.getAll()
        print("Количество записей в таблице: \(items.count)")
        
        let id = items[0].id
        print("Идентификатор для получения записи: \(id)")
        
        let item = dataManager.get(by: id)
        XCTAssertNotNil(item)
        print("Результат получения конкретной записи: \(item)")
        print("************************************************************************\n")
    }

    // MARK: - Tests insert()
    func tests_Insert_IdNotFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ДОБАВЛЕНИЕ ЗАПИСЕЙ С НОВЫМИ ИДЕНТИФИКАТОРАМИ")

        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()
        
        var count = dataManager.getAll().count
        print("Количество записей в таблице до операции INSERT: \(count)")
        
        for _ in count...(count + 5) {
            let item = TodoList()
            _ = dataManager.insert(item)
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице после опреации INSERT: \(allCount)")
        print("Количество добавленных записей в таблицу: \(allCount - count)")
        print("************************************************************************\n")
    }

    func tests_Insert_IdFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ДОБАВЛЕНИЕ ЗАПИСЕЙ С ИМЕЮЩИМИСЯ В ТАБЛИЦЕ ИДЕНТИФИКАТОРАМИ")

        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()
        
        let items = dataManager.getAll()
        var count = items.count
        print("Количество записей в таблице до операции INSERT: \(count)")

        for item in items {
            let foundedItem = dataManager.insert(item)
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице после операции INSERT: \(allCount)")
        print("Количество добавленных записей в таблицу: \(allCount - count)")
        print("************************************************************************\n")
    }

    // MARK: - Tests update()
    func tests_Update_IdNotFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ОБНОВЛЕНИЕ ЗАПИСЕЙ С НЕСОВПАДАЮЩИМИСЯ ИДЕНТИФИКАТОРАМИ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()
        
        let items = dataManager.getAll()
        print("Количество записей в таблице до операции UPDATE: \(items.count)")
        var count = 0
        for _ in 0...5 {
            let item = TodoList()
            let updateResult = dataManager.update(item)
            if updateResult != nil { count += 1 }
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице после операции UPDATE: \(allCount)")
        print("Количество обновленных записей в таблице: \(count)")
        print("************************************************************************\n")
    }

    func tests_Update_IdFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ОБНОВЛЕНИЕ ЗАПИСЕЙ С СОВПАДАЮЩИМИСЯ ИДЕНТИФИКАТОРАМИ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()

        var count = 0
        let items = dataManager.getAll()
        print("Количество записей в таблице до операции UPDATE: \(items.count)")
        
        for item in items {
            let updatedItem = TodoList(id: item.id, items: item.items, revision: item.revision + 1,
                                       isDirty: item.isDirty, lastUpdatedBy: "simulator", lastUpdatedOn: Date())
            let updateResult = dataManager.update(updatedItem)
            if updateResult != nil { count += 1 }
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице после операции UPDATE: \(allCount)")
        print("Количество обновленных записей в таблице: \(count)")
        print("************************************************************************\n")
    }

    // MARK: - Tests insertOrUpdate()
    func tests_InsertOrUpdate_IdNotFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ДОБАВЛЕНИЕ ИЛИ ОБНОВЛЕНИЕ ЗАПИСЕЙ С НЕСОВПАДАЮЩИМИСЯ ИДЕНТИФИКАТОРАМИ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()
        
        let items = dataManager.getAll()
        var count = items.count
        print("Количество записей в таблице до операции UPSERT: \(count)")
        
        for _ in count...(count + 5) {
            let item = TodoList()
            _ = dataManager.upsert(item)
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице после операции UPSERT: \(allCount)")
        print("Количество добавленных записей: \(allCount - count)")
        print("************************************************************************\n")
    }

    func tests_InsertOrUpdate_IdFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: ДОБАВЛЕНИЕ ИЛИ ОБНОВЛЕНИЕ ЗАПИСЕЙ С ОДИНАКОВЫМИ ИДЕНТИФИКАТОРАМИ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()

        let items = dataManager.getAll()
        var count = items.count
        print("Количество записей в таблице до операций UPSERT: \(count)")
        
        for item in items {
            let newItem = TodoList(id: item.id, items: item.items, revision: item.revision + 1,
                                   isDirty: item.isDirty, lastUpdatedBy: "simulator", lastUpdatedOn: Date())
            _ = dataManager.upsert(newItem)
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице после операции UPSERT: \(allCount)")
        print("Количество добавленных в таблице: \(allCount - count)")
        print("************************************************************************\n")
    }

    // MARK: - Tests delete()
    func tests_Delete_IdNotFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: УДАЛЕНИЕ ЗАПИСЕЙ КОГДА ИНДЕТИФИКАТОРЫ НЕ СОВПАДАЮТ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()

        var count = dataManager.getAll().count
        print("Количество записей в таблице до выполенения операций DELETE: \(count)")
        
        for idx in 1...count where idx % 2 == 0 {
            let newItem = TodoList()
            _ = dataManager.delete(by: newItem.id)
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице после операции DELETE: \(allCount)")
        print("Количество удаленных записей в таблице: \(count - allCount)")
        print("************************************************************************\n")
    }

    func tests_Delete_IdIsFound() throws {
        print("\n******************************** ТЕСТ *********************************")
        print("ПРОВЕРКА: УДАЛЕНИЕ ЗАПИСЕЙ КОГДА ИНДЕТИФИКАТОРЫ СОВПАДАЮТ")
        
        let filepath = TestsData.getFilepath(prefix: "TodoList", isTemp: false)
        dataManager.configure(name: filepath.filename, connectionUrl: filepath.url)
        _ = dataManager.load()

        let items = dataManager.getAll()
        let count = items.count
        print("Количество записей в таблице до операций DELETE: \(count)")
        
        for idx in 0..<count where idx % 2 == 0 {
            _ = dataManager.delete(by: items[idx].id)
        }
        
        _ = dataManager.save()
        _ = dataManager.load()
        let allCount = dataManager.getAll().count
        
        print("Количество записей в таблице : \(allCount)")
        print("Количество удаленных записей в таблице : \(count - allCount)")
        print("************************************************************************\n")
    }
}
