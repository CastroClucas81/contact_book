import 'package:contact_book/models/column_contact_table.dart';
import 'package:contact_book/models/contact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactHelper extends ColumnContactTable {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    // se o banco já está inicializado ele retorna o db
    // caso contrário cria um novo
    if (_db != null) {
      return _db;
    } else {
      return _db = await initDb();
    }
  }

  // criar db
  Future<Database?> initDb() async {
    // get db
    final databasesPath = await getDatabasesPath();

    // router file db
    final path = join(databasesPath, "contactsNew.db");

    // on create só cria uma vez
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact?> saveContact(Contact contact) async {
    Database? dbContact = await db;

    contact.id = await dbContact!.insert(contactTable, contact.toMap());

    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;

    List<Map> maps = await dbContact!.query(
      contactTable,
      columns: [
        idColumn,
        nameColumn,
        emailColumn,
        phoneColumn,
        imgColumn,
      ],
      where: "$idColumn = ?",
      whereArgs: [id],
    );

    if (maps.length > 0)
      return Contact.fromMap(maps.first);
    else
      return null;
  }

  Future<int> deleteContact(int id) async {
    Database? dbContact = await db;

    // return um numero inteiro
    return await dbContact!.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int?> updateContact(Contact contact) async {
    Database? dbContact = await db;

    // return um numero inteiro
    return await dbContact!.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List> getAllContacts() async {
    Database? dbContact = await db;

    List listMap = await dbContact!.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];

    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future<int?> getNumber() async {
    Database? dbContact = await db;

    return Sqflite.firstIntValue(
      await dbContact!.rawQuery("SELECT COUNT(*) FROM $contactTable"),
    );
  }

  Future close() async {
    Database? dbContact = await db;
    dbContact!.close();
  }
}
