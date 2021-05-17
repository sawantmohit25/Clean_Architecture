import 'package:clean_architecture_app/core/errors/exceptions.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences{}

void main(){
  NumberTriviaLocalDataSourceImpl dataSourceImpl;
  MockSharedPreferences mockSharedPreferences;
  setUp((){
    mockSharedPreferences=MockSharedPreferences();
    dataSourceImpl=NumberTriviaLocalDataSourceImpl( sharedPreferences:mockSharedPreferences);
  });

  group('getLastNumberTrivia',(){

    final tNumberTriviaModel=NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test('should return NumberTrivia from Shared Preferences when there is one', ()async{
      //arrange
      when(mockSharedPreferences.getString(any)).thenReturn(fixture('trivia_cached.json'));
      //act
      final result=await dataSourceImpl.getLastNumberTrivia();
      //assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result,equals(tNumberTriviaModel));
    });

    test('should throw a cached Exception when there is not a cached value', ()async{
      //arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      //act
      final call=dataSourceImpl.getLastNumberTrivia;
      //assert
      expect(()=>call(),throwsA(isInstanceOf<CacheException>()));
    });
  });

  group('cacheNumberTrivia',(){

    final tNumnberTriviaModel=NumberTriviaModel(text:'test trivia', number:1);

    test('should call shared preferences to cache the data', ()async{
      //act
      dataSourceImpl.cacheNumberTrivia(tNumnberTriviaModel);
      //assert
      final expectedJsonString=json.encode(tNumnberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA,expectedJsonString));
    });
  });
}