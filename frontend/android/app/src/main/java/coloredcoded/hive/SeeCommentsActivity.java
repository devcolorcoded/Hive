package coloredcoded.hive;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import java.util.Map;

import coloredcoded.hive.client.ActionType;
import coloredcoded.hive.client.Callback;
import coloredcoded.hive.client.Location;
import coloredcoded.hive.client.Post;
import coloredcoded.hive.client.QueryParams;
import coloredcoded.hive.client.Response;
import coloredcoded.hive.client.ServerClient;
import coloredcoded.hive.client.ServerClientImp;
import coloredcoded.hive.client.StatusOr;

public class SeeCommentsActivity extends AppCompatActivity implements CommentFeedManager.Delegate,
        PostView.Delegate {

    private ServerClient client;
    private CommentFeedManager commentFeedManager;
    private PostView postView;
    private Post post;
    private Button makeCommentButton;
    private EditText commentEditText;
    // Disallow the ability to make a comment.
    private boolean disallowMakingComments;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.see_comments_layout);

        // The only way we get here is from another activity transitioning to us. So we expect some
        // extra information regarding the post whose comments we are displaying.
        Intent intent = getIntent();
        post = (Post) intent.getSerializableExtra("post");
        disallowMakingComments = intent.getBooleanExtra("disallowMakingComments", false);
        ViewGroup parentGroup = (ViewGroup) getWindow().getDecorView().getRootView();
        postView = PostView.newInstance(post, findViewById(R.id.postViewShell),
                this, parentGroup);
        postView.disableAllButtons();

        client = new ServerClientImp();
        commentFeedManager = new CommentFeedManager(getApplicationContext());
        commentFeedManager.configure((ListView) findViewById(R.id.commentFeedListView),
                (SwipeRefreshLayout) findViewById(R.id.commentFeedSwipeRefresh), this);
        commentEditText = findViewById(R.id.commentEditText);
        if (disallowMakingComments) {
            commentEditText.setVisibility(View.INVISIBLE);
        }

        makeCommentButton = findViewById(R.id.makeCommentButton);
        makeCommentButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                makeCommentButton.setEnabled(false);
                String text = commentEditText.getText().toString();
                if (text.isEmpty()) {
                    return;
                }
                insertComment(text);
            }
        });
        if (disallowMakingComments) {
            makeCommentButton.setVisibility(View.INVISIBLE);
        }

        Button backButton = findViewById(R.id.seeCommentsBackButton);
        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();  // Pop activity off the stack.
            }
        });
    }

    private void insertComment(String text) {
        client.insertComment(testUser(), text, post.getPostId(),
                getInsertCommentCallback(), null);
    }

    private Callback getInsertCommentCallback() {
        return new Callback() {
            @Override
            public void serverRequestCallback(StatusOr<Response> responseOr,
                                              Map<String, Object> notes) {
                Response response = responseOr.get();
                commentFeedManager.pokeNew();
                commentEditText.post(new Runnable() {
                    @Override
                    public void run() {
                        commentEditText.getText().clear();
                        commentEditText.clearFocus();
                        // Hide keyboard
                        InputMethodManager mgr = (InputMethodManager) getSystemService(
                                Context.INPUT_METHOD_SERVICE);
                        mgr.hideSoftInputFromWindow(commentEditText.getWindowToken(), 0);
                    }
                });
                makeCommentButton.post(new Runnable() {
                    @Override
                    public void run() {
                        makeCommentButton.setEnabled(true);
                    }
                });
            }
        };
    }

    @Override
    public void fetchMoreComments(QueryParams queryParams) {
        client.getAllPostComments(post.getPostId(), queryParams,
                getAllPostCommentsCallback(), null);
    }

    public Callback getAllPostCommentsCallback() {
        return new Callback() {
            @Override
            public void serverRequestCallback(StatusOr<Response> responseOr,
                                              Map<String, Object> notes) {
                Response response = responseOr.get();
                commentFeedManager.addMoreComments(response.getComments(),
                        response.getQueryMetadata());
            }
        };
    }

    @Override
    public void commentButtonClick(PostView postView) {
        // Ignoring because we are already in the comment view.
    }

    @Override
    public void performAction(PostView postView, ActionType actionType) {
        // Ignoring for now.
    }

    public void setDisallowMakingComments(boolean disallow) {
        disallowMakingComments = disallow;
    }

    private Location testLocation() {
        return new Location("47.608013", "-122.335167",
                new Location.Area("47.60", "-122.33",
                        "Seattle", "WA", "United States"));
    }

    private String testUser() {
        return "user1";
    }
}