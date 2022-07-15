//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Blog {
    string public name;
    address public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    struct Post {
        uint256 id;
        string title;
        string content;
        bool published;
    }

    mapping(uint256 => Post) private map_idToPost;
    mapping(string => Post) private map_hashToPost;

    constructor(string memory _name) {
        console.log("Name of Blog being published:", _name);
        name = _name;
        owner = msg.sender;
    }

    function updateName(string memory _name) public {
        name = _name;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event PostCreated(uint256 id, string title, string hash);
    event PostUpdated(uint256 id, string title, string hash, bool published);

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function fetchPost(string memory hash) public view returns (Post memory) {
        return map_hashToPost[hash];
    }

    function createPost(string memory title, string memory hash)
        public
        onlyOwner
    {
        _postIds.increment();
        uint256 postId = _postIds.current();
        Post storage post = map_idToPost[postId];
        post.id = postId;
        post.title = title;
        post.published = true;
        post.content = hash;
        map_hashToPost[hash] = post;
        emit PostCreated(postId, title, hash);
    }

    function updatePost(
        uint256 postId,
        string memory title,
        string memory hash,
        bool published
    ) public onlyOwner {
        Post storage post = map_idToPost[postId];
        post.title = title;
        post.published = published;
        post.content = hash;
        map_idToPost[postId] = post;
        map_hashToPost[hash] = post;

        emit PostUpdated(post.id, title, hash, published);
    }

    function fetchPosts() public view returns (Post[] memory) {
        uint256 itemCount = _postIds.current();

        Post[] memory posts = new Post[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Post storage currentItem = map_idToPost[currentId];
            posts[i] = currentItem;
        }
        return posts;
    }
}
