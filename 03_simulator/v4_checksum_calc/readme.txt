IPv4のchecksumを計算します

使い方：
1.v4パケットのイメージを、改行/空白を削除し、"aaa.txt"と
  名前をつけて保存(aaa-checksum.shと同レベル)してください。

  ex) 0000 0000 0000 0000
      0000 0000 0000 0000
      0000 0000 0000 0000
               ↓
      00000000000000000000000000000000・・・


2."./aaa-checksum.txt"を実行！


3.packet_sizeとchecksumが出てきます。
  checksumは上位バイトと下位バイトをひっくり返してください。

  ex) packet size = 24
      fe98
            ↓
      packet size = 24バイト
      checksum    = 98fe