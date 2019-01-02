package hive;

public interface ServerClient {
	
	/*
	 * This is an interface that handles requests to the server.
	 * 
	 * You will notice that some functions require a QueryParams object. The server paginates some results. That is,
	 * it will only serve back a certain number of the total results. It is up to the client to keep track of this object as it will
	 * be used to tell the server where the last batch of results ended and where the next batch should begin.
	 * 
	 */
	
	// Returns a new server client. Please only use this function to get a ServerClient.
	// Do not call new ServerClientImp() directly as implementation can change.
	public static ServerClient newServerClient() {
		return new ServerClientImp();
	}

	void createUser(String username, String phoneNumber, Callback callback);
	void insertComment(String username, String commentText, String postId, Callback callback);
	void insertPost(String username, String postText, String location, Callback callback);
	void updatePost(String username, String postId, ActionType actionType, Callback callback);
	void getAllPostsAroundUser(String username, String location, QueryParams params, Callback callback);
	void getAllPostsByUser(String username, QueryParams params, Callback callback);
	void getAllPostsCommentedOnByUser(String username, QueryParams params, Callback callback);
	void getAllPostComments(String postId, QueryParams params, Callback callback);
	void getAllPopularPostsAtLocation(String username, String locationStr, QueryParams params, Callback callback);
	void getPopularLocations(Callback callback);
	
	// Please call shutdown when application is finished running to gracefully free the clients resources.
	void shutdown();
}