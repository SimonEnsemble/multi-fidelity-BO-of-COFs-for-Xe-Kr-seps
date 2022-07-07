import numpy as np
import torch


# find COF closest to the center of feature space
def get_initializing_COF(X):
    # center of feature space
    feature_center = np.ones(X.shape[1]) * 0.5
    # max possible distance between normalized features
    return np.argmin(np.linalg.norm(X - feature_center, axis=1))

# yields np.array([25, 494, 523])
def diverse_set(X, train_size):
    # total number of COFs in data set
    nb_COFs = X.shape[0]
    # initialize with one random point; pick others in a max diverse fashion
    ids_train = [get_initializing_COF(X)]
    # select remaining training points
    for j in range(train_size - 1):
        # for each point in data set, compute its min dist to training set
        dist_to_train_set = np.linalg.norm(X - X[ids_train, None, :], axis=2)
        assert np.shape(dist_to_train_set) == (len(ids_train), nb_COFs)
        min_dist_to_a_training_pt = np.min(dist_to_train_set, axis=0)
        assert np.size(min_dist_to_a_training_pt) == nb_COFs
        
        # acquire point with max(min distance to train set) i.e. Furthest from train set
        ids_train.append(np.argmax(min_dist_to_a_training_pt))
    assert np.size(np.unique(ids_train)) == train_size # must be unique
    return np.array(ids_train)
