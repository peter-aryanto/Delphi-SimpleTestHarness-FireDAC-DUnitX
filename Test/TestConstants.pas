unit TestConstants;

interface

const
  CTestResourcePath = '..\Resource\';
  
  CTestFbEmbeddedFile = CTestResourcePath + 'fbembed.dll';
  
  CTestDbFileName = 'TestDatabase';
  COriginalTestDbFile = CTestResourcePath + CTestDbFileName + '.fdb';
  CTestDbFileExtension = 'test';
  CTestDbFile = CTestResourcePath + CTestDbFileName + '.' + CTestDbFileExtension;

  CInitialDbVersionAsNumber = 3000;
  CInitialDbVersionAsText = '30.00';

implementation

end.
