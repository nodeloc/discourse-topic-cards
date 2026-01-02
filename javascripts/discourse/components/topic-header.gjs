import categoryLink from "discourse/helpers/category-link";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";

const TopicHeader = <template>
  <div class="topic-card__header">
    {{categoryLink @topic.category}}
    <span class="separator">•</span>
    <span class="author-info">
      Posted by
      <UserLink @user={{@topic.creator}}>
        <span class="username">u/{{@topic.creator.username}}</span>
      </UserLink>
    </span>
    <span class="separator">•</span>
    <span class="time-info">
      {{formatDate @topic.createdAt format="tiny"}}
    </span>
  </div>
</template>;

export default TopicHeader;
