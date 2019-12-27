import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import './model/raffles.dart';
import 'package:cekilismobil/database/model/participants.dart';
import 'package:cekilismobil/database/model/results.dart';


class DBHelper {
  static Database _db;
  static const String DB_NAME = 'raffles.db';

  //**Raffle Table**
  static const Raffle_Table_Name = "Raffles";
  static const Raffle_Id = "id";
  static const Raffle_Name = "name";
  static const Raffle_Description = "description";
  static const Raffle_Created_at = "createdat";
  static const Raffle_Updated_at = "updatedat";

  //**Participants Table**
  static const Participants_Table_Name = "Participants";
  static const Participants_Id = "id";
  static const Participants_Raffle_Id = "raffle_id";
  static const Participants_Participant = "participant";
  static const Participants_Created_at = "createdat";

  //**Raffle Results Table**
  static const Raffle_Results_Table_Name = "Results";
  static const Raffle_Results_Id = "id";
  static const Raffle_Results_Raffle_Id = "raffle_id";
  static const Raffle_Results_Status = "status";
  static const Raffle_Results_Participant = "participant";
  static const Raffle_Results_Created_at = "createdat";

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath , DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db
        .execute("CREATE TABLE $Raffle_Table_Name ($Raffle_Id INTEGER PRIMARY KEY AUTOINCREMENT, $Raffle_Name TEXT, $Raffle_Description TEXT, $Raffle_Created_at TEXT, $Raffle_Updated_at TEXT)");
    await db
        .execute("CREATE TABLE $Participants_Table_Name ($Participants_Id INTEGER PRIMARY KEY AUTOINCREMENT, $Participants_Raffle_Id INTEGER, $Participants_Participant TEXT, $Participants_Created_at TEXT)");
    await db
        .execute("CREATE TABLE $Raffle_Results_Table_Name ($Raffle_Results_Id INTEGER PRIMARY KEY AUTOINCREMENT, $Raffle_Results_Raffle_Id INTEGER, $Raffle_Results_Status INTEGER, $Raffle_Results_Participant TEXT, $Raffle_Results_Created_at TEXT)");
  }

  Future<int> saveRaffle(Raffles raffle) async {
    var dbClient = await db;
    var result = await dbClient.insert(Raffle_Table_Name, raffle.toMap());
    return result;
  }

  Future<List> getAllRaffles() async {
    var dbClient = await db;
    var result = await dbClient.query(Raffle_Table_Name, orderBy: "$Raffle_Id DESC");
    return result.toList();
  }

  Future<List> detailRaffle(var id) async {
    var dbClient = await db;
    var result = await dbClient.query(Raffle_Table_Name, where: "$Raffle_Id = ?", whereArgs: [id]);//
    return result.toList();
  }

  Future<int> getRaffleCount() async {
    var dbClient = await db;
    var count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $Raffle_Table_Name'));
    return count;
  }

  Future<int> updateRaffle(Raffles raffle,id) async {
    var dbClient = await db;
    return await dbClient.update(Raffle_Table_Name, raffle.toMap(), where: "$Raffle_Id = ?", whereArgs: [id]);
  }

  Future<Null> updateDatetimeRaffle(var id,String datetime) async {
    await updateRaffle(new Raffles('', '', '', datetime),id);
  }

  Future<int> deleteRaffle(int id) async {
    var dbClient = await db;
    return await dbClient.delete(Raffle_Table_Name, where: '$Raffle_Id = ?', whereArgs: [id]);
  }

  //Participants

  Future<int> saveParticipants(Participants participants) async {
    var dbClient = await db;
    var result = await dbClient.insert(Participants_Table_Name, participants.toMap());
    return result;
  }

  Future<List> getAllParticipants(var id) async {
    var dbClient = await db;
    var result = await dbClient.query(Participants_Table_Name,where: '$Participants_Raffle_Id = ?', whereArgs: [id], orderBy: "$Participants_Id DESC");
    return result.toList();
  }

  Future<int> getParticipantsCount(var id) async {
    var dbClient = await db;
    var count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $Participants_Table_Name WHERE $Participants_Raffle_Id = $id'));
    return count;
  }

  Future<int> getParticipantNameCount(var raffleID, var participantNAME) async {
    var dbClient = await db;
    var count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $Participants_Table_Name WHERE $Participants_Raffle_Id = "$raffleID" AND $Participants_Participant = "$participantNAME"'));
    return count;
  }

  Future<Null> deleteParticipant(var id) async {
    var dbClient = await db;
    await dbClient.delete(Participants_Table_Name, where: '$Participants_Id = ?', whereArgs: [id]);
  }

  Future<Null> deleteParticipants(var id) async {
    var dbClient = await db;
    await dbClient.delete(Participants_Table_Name, where: '$Participants_Raffle_Id = ?', whereArgs: [id]);
  }

  Future<List> getAllResults(var id) async {
    var dbClient = await db;
    var result = await dbClient.query(Raffle_Results_Table_Name,where: '$Raffle_Results_Raffle_Id = ?', whereArgs: [id], orderBy: "$Raffle_Results_Id DESC");
    return result.toList();
  }

  Future<int> saveResults(Results results) async {
    var dbClient = await db;
    var result = await dbClient.insert(Raffle_Results_Table_Name, results.toMap());
    return result;
  }

  Future<int> getResultsCount(var id) async {
    var dbClient = await db;
    var count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $Raffle_Results_Table_Name WHERE $Raffle_Results_Raffle_Id = $id'));
    return count;
  }

  Future<Null> deleteResults(var id) async {
    var dbClient = await db;
    await dbClient.delete(Raffle_Results_Table_Name, where: '$Raffle_Results_Raffle_Id = ?', whereArgs: [id]);
  }

  Future<Null> deleteFullRaffle(var id) async {
    var dbClient = await db;
    await dbClient.delete(Raffle_Results_Table_Name, where: '$Raffle_Results_Raffle_Id = ?', whereArgs: [id]);
    await dbClient.delete(Participants_Table_Name, where: '$Participants_Raffle_Id = ?', whereArgs: [id]);
    await dbClient.delete(Raffle_Table_Name, where: '$Raffle_Id = ?', whereArgs: [id]);
  }

}