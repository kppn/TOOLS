IPv4��checksum���v�Z���܂�

�g�����F
1.v4�p�P�b�g�̃C���[�W���A���s/�󔒂��폜���A"aaa.txt"��
  ���O�����ĕۑ�(aaa-checksum.sh�Ɠ����x��)���Ă��������B

  ex) 0000 0000 0000 0000
      0000 0000 0000 0000
      0000 0000 0000 0000
               ��
      00000000000000000000000000000000�E�E�E


2."./aaa-checksum.txt"�����s�I


3.packet_size��checksum���o�Ă��܂��B
  checksum�͏�ʃo�C�g�Ɖ��ʃo�C�g���Ђ�����Ԃ��Ă��������B

  ex) packet size = 24
      fe98
            ��
      packet size = 24�o�C�g
      checksum    = 98fe