# -*- mode: python -*-
a = Analysis([os.path.join(HOMEPATH,'support\\_mountzlib.py'), os.path.join(HOMEPATH,'support\\useUnicode.py'), 'keytool.py'],
             pathex=['C:\\Users\\Administrator\\Documents\\wingit\\keytool'])
pyz = PYZ(a.pure)
exe = EXE( pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name=os.path.join('dist', 'keytool.exe'),
          debug=False,
          strip=False,
          upx=True,
          console=True )
