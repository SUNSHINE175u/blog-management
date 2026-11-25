package com.blog.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.blog.common.BusinessException;
import com.blog.dto.ArticleRequest;
import com.blog.dto.ArticleVO;
import com.blog.dto.TagVO;
import com.blog.entity.*;
import com.blog.mapper.*;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class ArticleService {

    private final ArticleMapper articleMapper;
    private final CategoryMapper categoryMapper;
    private final TagMapper tagMapper;
    private final ArticleTagMapper articleTagMapper;
    private final UserMapper userMapper;

    public ArticleService(ArticleMapper articleMapper, CategoryMapper categoryMapper,
                          TagMapper tagMapper, ArticleTagMapper articleTagMapper,
                          UserMapper userMapper) {
        this.articleMapper = articleMapper;
        this.categoryMapper = categoryMapper;
        this.tagMapper = tagMapper;
        this.articleTagMapper = articleTagMapper;
        this.userMapper = userMapper;
    }

    public Page<ArticleVO> listPublic(int page, int size, Long categoryId, Long tagId, String keyword) {
        return listArticles(page, size, categoryId, tagId, keyword, 1, false);
    }

    public Page<ArticleVO> listAdmin(int page, int size, Integer status, String keyword, boolean includeDeleted) {
        LambdaQueryWrapper<Article> wrapper = buildWrapper(null, null, keyword, status, includeDeleted);
        wrapper.orderByDesc(Article::getCreateTime);
        Page<Article> articlePage = articleMapper.selectPage(new Page<>(page, size), wrapper);
        return convertPage(articlePage);
    }

    private Page<ArticleVO> listArticles(int page, int size, Long categoryId, Long tagId,
                                         String keyword, Integer status, boolean includeDeleted) {
        LambdaQueryWrapper<Article> wrapper = buildWrapper(categoryId, tagId, keyword, status, includeDeleted);
        wrapper.orderByDesc(Article::getCreateTime);
        Page<Article> articlePage = articleMapper.selectPage(new Page<>(page, size), wrapper);
        return convertPage(articlePage);
    }

    private LambdaQueryWrapper<Article> buildWrapper(Long categoryId, Long tagId, String keyword,
                                                     Integer status, boolean includeDeleted) {
        LambdaQueryWrapper<Article> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null) {
            wrapper.eq(Article::getCategoryId, categoryId);
        }
        if (status != null) {
            wrapper.eq(Article::getStatus, status);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(Article::getTitle, keyword);
        }
        if (tagId != null) {
            List<ArticleTag> relations = articleTagMapper.selectList(
                    new LambdaQueryWrapper<ArticleTag>().eq(ArticleTag::getTagId, tagId));
            if (relations.isEmpty()) {
                wrapper.eq(Article::getId, -1);
            } else {
                wrapper.in(Article::getId, relations.stream().map(ArticleTag::getArticleId).toList());
            }
        }
        return wrapper;
    }

    public ArticleVO getPublicDetail(Long id) {
        Article article = articleMapper.selectById(id);
        if (article == null || article.getStatus() != 1) {
            throw new BusinessException("文章不存在");
        }
        article.setViewCount(article.getViewCount() + 1);
        articleMapper.updateById(article);
        return toVO(article, true);
    }

    public ArticleVO getAdminDetail(Long id) {
        Article article = articleMapper.selectById(id);
        if (article == null) {
            throw new BusinessException("文章不存在");
        }
        return toVO(article, true);
    }

    @Transactional
    public Long create(ArticleRequest request, Long authorId) {
        Article article = new Article();
        BeanUtils.copyProperties(request, article);
        article.setAuthorId(authorId);
        article.setViewCount(0);
        articleMapper.insert(article);
        saveTags(article.getId(), request.getTagIds());
        return article.getId();
    }

    @Transactional
    public void update(Long id, ArticleRequest request) {
        Article article = articleMapper.selectById(id);
        if (article == null) {
            throw new BusinessException("文章不存在");
        }
        BeanUtils.copyProperties(request, article);
        articleMapper.updateById(article);
        articleTagMapper.delete(new LambdaQueryWrapper<ArticleTag>().eq(ArticleTag::getArticleId, id));
        saveTags(id, request.getTagIds());
    }

    public void delete(Long id) {
        if (articleMapper.selectById(id) == null) {
            throw new BusinessException("文章不存在");
        }
        articleMapper.deleteById(id);
    }

    public void restore(Long id) {
        if (articleMapper.restoreById(id) == 0) {
            throw new BusinessException("文章不存在或未被删除");
        }
    }

    public void permanentDelete(Long id) {
        articleTagMapper.delete(new LambdaQueryWrapper<ArticleTag>().eq(ArticleTag::getArticleId, id));
        if (articleMapper.physicalDeleteById(id) == 0) {
            throw new BusinessException("文章不存在");
        }
    }

    public Page<ArticleVO> listDeleted(int page, int size) {
        Page<Article> articlePage = articleMapper.selectDeletedPage(new Page<>(page, size));
        return convertPage(articlePage);
    }

    private void saveTags(Long articleId, List<Long> tagIds) {
        if (tagIds == null || tagIds.isEmpty()) {
            return;
        }
        for (Long tagId : tagIds) {
            ArticleTag at = new ArticleTag();
            at.setArticleId(articleId);
            at.setTagId(tagId);
            articleTagMapper.insert(at);
        }
    }

    private Page<ArticleVO> convertPage(Page<Article> articlePage) {
        Page<ArticleVO> voPage = new Page<>(articlePage.getCurrent(), articlePage.getSize(), articlePage.getTotal());
        voPage.setRecords(articlePage.getRecords().stream()
                .map(a -> toVO(a, false))
                .collect(Collectors.toList()));
        return voPage;
    }

    private ArticleVO toVO(Article article, boolean withContent) {
        ArticleVO vo = new ArticleVO();
        BeanUtils.copyProperties(article, vo);
        if (!withContent) {
            vo.setContent(null);
        }
        if (article.getCategoryId() != null) {
            Category category = categoryMapper.selectById(article.getCategoryId());
            if (category != null) {
                vo.setCategoryName(category.getName());
            }
        }
        User author = userMapper.selectById(article.getAuthorId());
        if (author != null) {
            vo.setAuthorName(author.getNickname());
        }
        vo.setTags(getTagsByArticleId(article.getId()));
        return vo;
    }

    private List<TagVO> getTagsByArticleId(Long articleId) {
        List<ArticleTag> relations = articleTagMapper.selectList(
                new LambdaQueryWrapper<ArticleTag>().eq(ArticleTag::getArticleId, articleId));
        if (relations.isEmpty()) {
            return Collections.emptyList();
        }
        List<Long> tagIds = relations.stream().map(ArticleTag::getTagId).toList();
        return tagMapper.selectBatchIds(tagIds).stream().map(tag -> {
            TagVO tv = new TagVO();
            tv.setId(tag.getId());
            tv.setName(tag.getName());
            return tv;
        }).collect(Collectors.toList());
    }

    public List<ArticleVO> listLatest(int limit) {
        LambdaQueryWrapper<Article> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Article::getStatus, 1).orderByDesc(Article::getCreateTime).last("LIMIT " + limit);
        return articleMapper.selectList(wrapper).stream()
                .map(a -> toVO(a, false))
                .collect(Collectors.toList());
    }
}
