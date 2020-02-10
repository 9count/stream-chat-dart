import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat/stream_chat.dart';
import 'package:stream_chat_example/components/user_avatar.dart';

import '../channel.bloc.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    Key key,
    @required this.previousMessage,
    @required this.message,
    @required this.nextMessage,
  }) : super(key: key);

  final Message previousMessage;
  final Message message;
  final Message nextMessage;

  @override
  Widget build(BuildContext context) {
    final channelBloc = Provider.of<ChannelBloc>(context);
    final currentUserId = channelBloc.chatBloc.user.id;
    final messageUserId = message.user.id;
    final previousUserId = previousMessage?.user?.id;
    final nextUserId = nextMessage?.user?.id;
    final bool isMyMessage = messageUserId == currentUserId;
    final isLastUser = previousUserId == messageUserId;
    final isNextUser = nextUserId == messageUserId;

    List<Widget> row = <Widget>[
      Container(
        width: MediaQuery.of(context).size.width - 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment:
                  isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                decoration: _buildBoxDecoration(isMyMessage, isLastUser),
                padding: EdgeInsets.all(10),
                constraints: BoxConstraints.loose(Size.fromWidth(300)),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            isNextUser ? Container() : _buildTimestamp(isMyMessage),
          ],
        ),
      ),
      isNextUser
          ? Container(
              width: 40,
            )
          : Padding(
              padding: EdgeInsets.only(
                  left: isMyMessage ? 8.0 : 0, right: isMyMessage ? 0 : 8.0),
              child: UserAvatar(user: message.user),
            ),
    ];

    if (!isMyMessage) {
      row = row.reversed.toList();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      margin: EdgeInsets.only(
        top: isLastUser ? 5 : 24,
        bottom: nextMessage == null ? 30 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: row,
      ),
    );
  }

  Align _buildTimestamp(bool isMyMessage) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        formatDate(message.createdAt.toLocal(), [HH, ':', nn]),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(bool isMyMessage, bool isLastUser) {
    return BoxDecoration(
      border: isMyMessage ? null : Border.all(color: Colors.black.withAlpha(8)),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular((isMyMessage || !isLastUser) ? 16 : 2),
        bottomLeft: Radius.circular(isMyMessage ? 16 : 2),
        topRight: Radius.circular((isMyMessage && isLastUser) ? 2 : 16),
        bottomRight: Radius.circular(isMyMessage ? 2 : 16),
      ),
      color: isMyMessage ? Color(0xffebebeb) : Colors.white,
    );
  }
}