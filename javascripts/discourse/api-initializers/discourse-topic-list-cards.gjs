import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import { hash } from "@ember/helper";
import TopicExcerpt from "../components/topic-excerpt";
import TopicMetadata from "../components/topic-metadata";
import TopicHeader from "../components/topic-header";
import TopicLastReply from "../components/topic-last-reply";
import TopicTags from "../components/topic-tags";
import TopicOp from "../components/topic-op";
import TopicTagsMobile from "../components/topic-tags-mobile";
import TopicThumbnail from "../components/topic-thumbnail";
import PluginOutlet from "discourse/components/plugin-outlet";
import TopicStatus from "discourse/components/topic-status";

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");
  const router = api.container.lookup("service:router");

  function enableCards() {
    if (router.currentRouteName === "topic.fromParamsNear") {
      return settings.show_for_suggested_topics;
    }

    if (settings.show_on_categories?.length === 0) {
      return true; // no categories set, so enable cards by default
    }
    const currentCat = router.currentRoute?.attributes?.category?.id;
    if (currentCat === undefined) {
      return false; // not in a category
    }
    const categoryIds = settings.show_on_categories?.split("|").map(Number);
    return categoryIds.includes(currentCat);
  }

  api.renderInOutlet(
    "topic-list-main-link-bottom",
    class extends Component {
      static shouldRender(args, context) {
        return (
          context.siteSettings.glimmer_topic_list_mode !== "disabled" &&
          enableCards()
        );
      }

      <template>
        {{! 第一行：Header + Tags }}
        <div class="topic-card__header-row">
          <TopicHeader @topic={{@outletArgs.topic}} />
          <TopicTags @topic={{@outletArgs.topic}} />
        </div>
        
        {{! 第二行：内容区域 + 缩略图 }}
        <div class="topic-card__content-row">
          <div class="topic-card__main-content">
            <h3 class="topic-card__title">
              <TopicStatus @topic={{@outletArgs.topic}} @disableActions={{true}} />
              <a href={{@outletArgs.topic.url}} class="topic-card__title-link">
                {{@outletArgs.topic.title}}
              </a>
            </h3>
            <TopicExcerpt @topic={{@outletArgs.topic}} />
          </div>
          <div class="topic-card__thumb-wrapper">
            <TopicThumbnail @topic={{@outletArgs.topic}} />
          </div>
        </div>
        
        {{! 第三行：最后回复和 Metadata }}
        <div class="topic-card__footer-row">
          <TopicLastReply @topic={{@outletArgs.topic}} />
          <TopicMetadata @topic={{@outletArgs.topic}} />
        </div>
      </template>
    }
  );

  api.registerValueTransformer(
    "topic-list-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        additionalClasses.push("topic-cards-list");
      }
      return additionalClasses;
    }
  );

  const classNames = ["topic-card"];

  if (settings.set_card_max_height) {
    classNames.push("has-max-height");
  }

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        return [...additionalClasses, ...classNames];
      } else {
        return additionalClasses;
      }
    }
  );

  api.registerValueTransformer("topic-list-item-mobile-layout", ({ value }) => {
    if (enableCards()) {
      return false;
    }
    return value;
  });

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (enableCards()) {
      // 移除独立的缩略图列，改为在 outlet 中渲染
      // columns.add("thumbnail", { item: TopicThumbnail }, { before: "topic" });

      if (site.mobileView) {
        columns.add(
          "tags-mobile",
          { item: TopicTagsMobile },
          { before: "topic" }
        );
      }
    }
    return columns;
  });

  api.registerBehaviorTransformer(
    "topic-list-item-click",
    ({ context, next }) => {
      if (enableCards()) {
        const targetElement = context.event.target;
        const topic = context.topic;

        // Don't intercept clicks on user links and category links
        if (targetElement.closest(".user-link, a[data-user-card], .category-link-wrapper, .badge-category")) {
          return true;
        }

        const clickTargets = [
          "topic-list-data",
          "link-bottom-line",
          "link-top-line",
          "title",
          "topic-list-item",
          "topic-card__excerpt",
          "topic-card__excerpt-text",
          "topic-card__metadata",
          "topic-card__likes",
          "topic-card__op",
          "topic-card__last-reply",
          "topic-card__header",
          "topic-card__topic-tags",
        ];

        if (site.mobileView) {
          clickTargets.push("topic-item-metadata");
        }

        if (clickTargets.some((t) => targetElement.closest(`.${t}`))) {
          if (wantsNewWindow(context.event)) {
            return true;
          }
          context.event.preventDefault();
          return context.navigateToTopic(topic, topic.lastUnreadUrl);
        }
      }

      next();
    }
  );
});
