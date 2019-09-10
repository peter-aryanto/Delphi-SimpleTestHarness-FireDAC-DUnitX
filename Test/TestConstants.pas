unit TestConstants;

interface

const
  CTestResourcePath = '..\Resource\';
  
  CTestFbEmbeddedFile = CTestResourcePath + 'fbembed.dll';
  
  CTestDbFileName = 'TestDatabase';
  COriginalTestDbFile = CTestResourcePath + CTestDbFileName + '.fdb';
  CTestDbFileExtension = 'test';
  CTestDbFile = CTestResourcePath + CTestDbFileName + '.' + CTestDbFileExtension;

  CInitialDbVersionAsInteger = 3000;
  CInitialDbVersionAsString = '30.00';

implementation

end.
