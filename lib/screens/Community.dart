import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 243, 241), // Tan appbar
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Image.asset(
            'assets/logo.png', // Make sure to add this asset
            width: 20,
            height: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              'BorkTok Community',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: 22,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: const Color.fromARGB(60, 0, 0, 0),
          tabs: const [
            Tab(text: 'Personal Chats', icon: Icon(Icons.person)),
            Tab(text: 'Breed Groups', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PersonalChatsSection(),
          BreedGroupChatsSection(),
        ],
      ),
    );
  }
}

class PersonalChatsSection extends StatefulWidget {
  @override
  _PersonalChatsSectionState createState() => _PersonalChatsSectionState();
}

class _PersonalChatsSectionState extends State<PersonalChatsSection> {
  final List<ChatUser> _users = [
    ChatUser(
      id: '1',
      firstName: 'Sydney',
      lastName: 'Sweeny',
      profileImage: '',
    ),
    ChatUser(
      id: '2',
      firstName: 'Mitthu ',
      lastName: 'Don',
      profileImage: '',
    ),
    ChatUser(
      id: '3',
      firstName: 'Encore',
      lastName: 'ABJ',
      profileImage: '',
    ),
    ChatUser(
      id: '4',
      firstName: 'They call him',
      lastName: 'Calm',
      profileImage: '',
    ),
    ChatUser(
      id: '5',
      firstName: 'Raftarr',
      lastName: ' ',
      profileImage: '',
    ),
    ChatUser(
      id: '6',
      firstName: 'Krsna',
      lastName: '(\$ Sign)',
      profileImage: '',
    ),
    ChatUser(
      id: '7',
      firstName: 'Dino',
      lastName: 'James',
      profileImage: '',
    ),
    ChatUser(
      id: '8',
      firstName: 'Emily',
      lastName: 'Anderson',
      profileImage: '',
    ),
    ChatUser(
      id: '9',
      firstName: 'Daniel',
      lastName: 'Thomas',
      profileImage: '',
    ),
    ChatUser(
      id: '10',
      firstName: 'Ava',
      lastName: 'Jackson',
      profileImage: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.brown[200],
        height: 1,
        indent: 80,
      ),
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                radius: 30,
                child: Text(
                  user.firstName![0],
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            '${user.firstName} ${user.lastName}',
            style: TextStyle(
              color: Colors.brown[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Last message preview...',
            style: TextStyle(color: Colors.brown[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '2m ago',
                style: TextStyle(
                  color: Colors.brown[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(chatUser: user),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final ChatUser chatUser;

  const ChatDetailPage({Key? key, required this.chatUser}) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final List<ChatMessage> _messages = [];
  final ChatUser _currentUser = ChatUser(
    id: '0',
    firstName: 'Me',
    lastName: '',
    profileImage: '',
  );

  void _sendMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Text(
                widget.chatUser.firstName![0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.chatUser.firstName} ${widget.chatUser.lastName}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: DashChat(
        currentUser: _currentUser,
        onSend: (ChatMessage message) {
          _sendMessage(
            ChatMessage(
              user: _currentUser,
              createdAt: DateTime.now(),
              text: message.text,
            ),
          );
        },
        messages: _messages,
        messageOptions: MessageOptions(
          textColor: Colors.brown[800]!,
          currentUserTextColor: Colors.white,
          currentUserContainerColor: Theme.of(context).primaryColor,
          containerColor: Colors.brown[200]!,
          messageDecorationBuilder: (message, previousMessage, nextMessage) {
            return BoxDecoration(
              color: message.user.id == _currentUser.id 
                ? Theme.of(context).primaryColor 
                : Colors.brown[200],
              borderRadius: BorderRadius.circular(12),
            );
          },
        ),
        inputOptions: InputOptions(
          alwaysShowSend: true,
          sendButtonBuilder: (onSend) {
            return IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onSend,
            );
          },
          inputDecoration: InputDecoration(
            hintText: 'Type a message...',
            hintStyle: TextStyle(color: Colors.brown[500]),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class BreedGroupChatsSection extends StatelessWidget {
  final List<String> _dogBreeds = [
    'Labrador Retriever',
    'German Shepherd',
    'Golden Retriever',
    'French Bulldog',
    'Poodle',
    'Bulldog',
    'Beagle',
    'Rottweiler',
    'Dachshund',
    'Yorkshire Terrier',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _dogBreeds.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.brown[200],
        height: 1,
        indent: 80,
      ),
      itemBuilder: (context, index) {
        final breed = _dogBreeds[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            radius: 30,
            child: Text(
              breed[0],
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          title: Text(
            '$breed Group',
            style: TextStyle(
              color: Colors.brown[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Community chat for ${breed} lovers',
            style: TextStyle(color: Colors.brown[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${(index + 10) * 3} members',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupChatDetailPage(groupName: breed),
              ),
            );
          },
        );
      },
    );
  }
}

class GroupChatDetailPage extends StatefulWidget {
  final String groupName;

  const GroupChatDetailPage({Key? key, required this.groupName}) : super(key: key);

  @override
  _GroupChatDetailPageState createState() => _GroupChatDetailPageState();
}

class _GroupChatDetailPageState extends State<GroupChatDetailPage> {
  final List<ChatMessage> _messages = [];
  final ChatUser _currentUser = ChatUser(
    id: '0',
    firstName: 'Me',
    lastName: '',
    profileImage: '',
  );

  void _sendMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          '${widget.groupName} Group',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: DashChat(
        currentUser: _currentUser,
        onSend: (ChatMessage message) {
          _sendMessage(
            ChatMessage(
              user: _currentUser,
              createdAt: DateTime.now(),
              text: message.text,
            ),
          );
        },
        messages: _messages,
        messageOptions: MessageOptions(
          textColor: Colors.brown[800]!,
          currentUserTextColor: Colors.white,
          currentUserContainerColor: Theme.of(context).primaryColor,
          containerColor: Colors.brown[200]!,
          messageDecorationBuilder: (message, previousMessage, nextMessage) {
            return BoxDecoration(
              color: message.user.id == _currentUser.id 
                ? Theme.of(context).primaryColor 
                : Colors.brown[200],
              borderRadius: BorderRadius.circular(12),
            );
          },
        ),
        inputOptions: InputOptions(
          alwaysShowSend: true,
          sendButtonBuilder: (onSend) {
            return IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onSend,
            );
          },
          inputDecoration: InputDecoration(
            hintText: 'Type a message...',
            hintStyle: TextStyle(color: Colors.brown[500]),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}