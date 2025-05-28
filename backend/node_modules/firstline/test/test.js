'use strict';

const promisify = require('js-promisify');
const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const fs = require('fs');
const path = require('path');
const rimraf = require('rimraf');

const firstline = require('../index.js');
const mocks = require('./mocks.js');

chai.should();
chai.use(chaiAsPromised);

describe('firstline', function () {

  const dirPath = path.join(__dirname, 'tmp/');
  const filePath = dirPath + 'test.txt';
  const wrongFilePath = dirPath + 'no-test.txt';

  before(function () {
    // Make "tmp" folder
    fs.mkdirSync(dirPath);
  });

  after(function () {
    // Delete "tmp" folder
    rimraf.sync(dirPath);
  });

  describe('#check', function () {

    afterEach(function () {
      // Delete mock CSV file
      rimraf.sync(filePath);
    });

    it('should reject if the file does not exist', function () {
      return firstline(wrongFilePath).should.be.rejected;
    });

    it('should return the first line of a file and default to `\\n` line ending', function () {
      return promisify(fs.writeFile, [filePath, 'abc\ndef\nghi'])
        .then(function () {
          return firstline(filePath).should.eventually.equal('abc');
        });
    });

    it('should work correctly if the first line is long', function () {
      return promisify(fs.writeFile, [filePath, mocks.longLine])
        .then(function () {
          return firstline(filePath).should.eventually.equal(mocks.longLine.split('\n')[0]);
        });
    });

    it('should return an empty line if the file is empty', function () {
      return promisify(fs.writeFile, [filePath, ''])
        .then(function () {
          return firstline(filePath).should.eventually.equal('');
        });
    });

    it('should work with a different line ending when specified correctly', function () {
      return promisify(fs.writeFile, [filePath, 'abc\rdef\rghi'])
        .then(function () {
          return firstline(filePath, '\r').should.eventually.equal('abc');
        });
    });

    it('should return the entire file if the specified line ending is wrong', function () {
      return promisify(fs.writeFile, [filePath, 'abc\ndef\nghi'])
        .then(function () {
          return firstline(filePath, '\r').should.eventually.equal('abc\ndef\nghi');
        });
    });

    it('should handle BOM', function () {
      return promisify(fs.writeFile, [filePath, '\uFEFFabc\ndef'])
        .then(function () {
          return firstline(filePath).should.eventually.equal('abc');
        });
    });

  });

});
