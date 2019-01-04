package hive;

import org.json.simple.JSONObject;

public final class Comment {
	
	private String commentId;
	// Username of comment author
	private String username;
	private String postId;
	private String commentText;
	private double creationTimestampSec;
	private JSONObject jsonComment;
	
	private Comment(String commentId, String username, String postId, String commentText, 
			double creationTimestampSec, JSONObject jsonComment) {
		this.commentId = commentId;
		this.username = username;
		this.postId = postId;
		this.commentText = commentText;
		this.creationTimestampSec = creationTimestampSec;
		this.jsonComment = jsonComment;
	}
	
	public Double getCreationTimestampSec() {
		return creationTimestampSec;
	}
	
	public long getCreationTimestampSecAsLong() {
		return Double.valueOf(creationTimestampSec).longValue();
	}

	public String getCommentId() {
		return commentId;
	}

	public String getUsername() {
		return username;
	}

	public String getPostId() {
		return postId;
	}

	public String getCommentText() {
		return commentText;
	}
	
	public String toString() {
		return jsonComment.toJSONString();
	}
	
	public static Comment jsonToComment(JSONObject jsonComment) {
		double timestamp = Double.parseDouble((String)jsonComment.get("creation_timestamp_sec"));
		System.out.println(timestamp);
		return new Comment((String)jsonComment.get("comment_id"), (String)jsonComment.get("username"), 
				(String)jsonComment.get("post_id"), (String)jsonComment.get("comment_text"), 
				timestamp, jsonComment);
	}
}