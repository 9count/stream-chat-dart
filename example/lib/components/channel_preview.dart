import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat/stream_chat.dart';
import 'package:stream_chat_example/components/channel.dart';
import 'package:stream_chat_example/components/channel_image.dart';

import '../channel.bloc.dart';
import 'channel_name_text.dart';

class ChannelPreview extends StatefulWidget {
  @override
  _ChannelPreviewState createState() => _ChannelPreviewState();
}

class _ChannelPreviewState extends State<ChannelPreview>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ChannelBloc>(
      builder: (context, channelBloc, _) => StreamBuilder<ChannelState>(
          stream: channelBloc.channelState,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            final channelState = snapshot.data;
            return StreamBuilder<bool>(
                stream: channelBloc.read,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  final read = snapshot.data;
                  return RawMaterialButton(
                    elevation: 0,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    onPressed: () {
                      _navigateToChannel(context, channelBloc);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          ChannelImage(
                            channel: channelState.channel,
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ChannelNameText(
                                    channel: channelState.channel,
                                  ),
                                  _buildSubtitle(
                                    channelBloc,
                                    read,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              StreamBuilder<DateTime>(
                                  stream: channelBloc.messages
                                      .map((message) => message.last.createdAt),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    return _buildDate(snapshot.data.toLocal());
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }

  Text _buildDate(DateTime lastMessageAt) {
    String stringDate;
    final now = DateTime.now();

    if (now.difference(lastMessageAt).inDays > 0) {
      stringDate =
          '${lastMessageAt.day}/${lastMessageAt.month}/${lastMessageAt.year}';
      stringDate = formatDate(lastMessageAt, [dd, '/', mm, '/', yyyy]);
    } else {
      stringDate = '${lastMessageAt.hour}:${lastMessageAt.minute}';
      stringDate = formatDate(lastMessageAt, [HH, ':', nn]);
    }

    return Text(
      stringDate,
      style: TextStyle(
        color: Colors.black.withOpacity(0.5),
        fontSize: 11,
      ),
    );
  }

  StreamBuilder<bool> _buildSubtitle(
    ChannelBloc channelBloc,
    bool read,
  ) {
    return StreamBuilder<bool>(
        stream: channelBloc.typing,
        initialData: false,
        builder: (context, snapshot) {
          final typing = snapshot.data;
          return typing
              ? Text(
                  'Typing...',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.black.withOpacity(!read ? 1 : 0.5),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : StreamBuilder<Message>(
                  stream: channelBloc.messages.map((event) => event.last),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data?.text ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black.withOpacity(!read ? 1 : 0.5),
                        fontSize: 13,
                      ),
                    );
                  },
                );
        });
  }

  void _navigateToChannel(BuildContext context, ChannelBloc channelBloc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider.value(
            value: channelBloc,
            child: ChannelWidget(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
